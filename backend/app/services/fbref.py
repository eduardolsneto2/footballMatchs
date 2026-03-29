from dataclasses import dataclass
from datetime import datetime
import json
from typing import Dict, List, Optional

import httpx
from bs4 import BeautifulSoup

from app.config import get_settings


settings = get_settings()


@dataclass(frozen=True)
class ScrapedFixture:
    competition: str
    kickoff: datetime
    home_team: str
    away_team: str
    status: str
    score: Optional[str]
    venue: Optional[str]
    source_url: str


class FBrefScraper:
    def __init__(self) -> None:
        self.headers = {
            "User-Agent": "FootballPulseScraper/0.1 (+https://github.com/eduardoleite/footballMatchs)"
        }

    async def scrape(self, config_json: str) -> List[ScrapedFixture]:
        config: Dict[str, object] = json.loads(config_json)
        mode = config.get("mode")
        urls = [url for url in config.get("urls", []) if isinstance(url, str)]

        async with httpx.AsyncClient(
            timeout=settings.scrape_timeout_seconds,
            headers=self.headers,
            follow_redirects=True,
        ) as client:
            if mode == "competition_schedule":
                competition_name = str(config.get("competition_name", "Competition"))
                fixtures = await self._scrape_urls(client, urls, competition_name)
                return self._sorted_unique(fixtures)

            if mode == "team_from_competitions":
                team_name = str(config.get("team_name", "")).strip()
                fixtures = await self._scrape_urls(client, urls, None)
                filtered = [
                    fixture
                    for fixture in fixtures
                    if self._matches_team_name(fixture.home_team, team_name)
                    or self._matches_team_name(fixture.away_team, team_name)
                ]
                return self._sorted_unique(filtered)

        return []

    async def _scrape_urls(
        self,
        client: httpx.AsyncClient,
        urls: List[str],
        override_competition_name: Optional[str],
    ) -> List[ScrapedFixture]:
        fixtures: List[ScrapedFixture] = []

        for url in urls:
            response = await client.get(url)
            response.raise_for_status()
            fixtures.extend(
                self.parse_schedule_html(
                    response.text,
                    source_url=url,
                    override_competition_name=override_competition_name,
                )
            )

        return fixtures

    def parse_schedule_html(
        self,
        html: str,
        source_url: str,
        override_competition_name: Optional[str] = None,
    ) -> List[ScrapedFixture]:
        soup = BeautifulSoup(html.replace("<!--", "").replace("-->", ""), "html.parser")
        tables = soup.find_all("table")
        fixtures: List[ScrapedFixture] = []

        for table in tables:
            header_keys = self._header_keys(table)
            if {"date", "home_team", "away_team"}.issubset(set(header_keys)) is False:
                continue

            competition_name = override_competition_name or self._competition_name_from_page(soup)

            for row in table.select("tbody tr"):
                if "thead" in row.get("class", []):
                    continue

                values = self._row_values(row)
                fixture = self._fixture_from_values(
                    values=values,
                    competition_name=competition_name,
                    source_url=source_url,
                )
                if fixture is not None:
                    fixtures.append(fixture)

        return fixtures

    def _fixture_from_values(
        self,
        values: Dict[str, str],
        competition_name: str,
        source_url: str,
    ) -> Optional[ScrapedFixture]:
        home_team = values.get("home_team", "").strip()
        away_team = values.get("away_team", "").strip()
        raw_date = values.get("date", "").strip()

        if not raw_date or not home_team or not away_team:
            return None

        kickoff = self._parse_kickoff(raw_date, values.get("start_time", "").strip())
        score = values.get("score", "").strip() or None
        status = "FT" if score else "NS"

        return ScrapedFixture(
            competition=competition_name,
            kickoff=kickoff,
            home_team=home_team,
            away_team=away_team,
            status=status,
            score=score,
            venue=values.get("venue", "").strip() or None,
            source_url=source_url,
        )

    def _parse_kickoff(self, raw_date: str, raw_time: str) -> datetime:
        normalized = raw_date
        if raw_time:
            normalized = f"{raw_date} {raw_time}"

        for fmt in ("%Y-%m-%d %H:%M", "%Y-%m-%d", "%d/%m/%Y %H:%M", "%d/%m/%Y"):
            try:
                return datetime.strptime(normalized, fmt)
            except ValueError:
                continue

        return datetime.fromisoformat(raw_date)

    def _row_values(self, row) -> Dict[str, str]:
        values: Dict[str, str] = {}
        for cell in row.find_all(["th", "td"]):
            key = cell.get("data-stat")
            if not key:
                continue
            values[key] = cell.get_text(" ", strip=True)
        return values

    def _header_keys(self, table) -> List[str]:
        header_row = table.select_one("thead tr")
        if header_row is None:
            return []
        return [cell.get("data-stat", "") for cell in header_row.find_all(["th", "td"])]

    def _competition_name_from_page(self, soup: BeautifulSoup) -> str:
        title = soup.select_one("h1")
        if title:
            return title.get_text(" ", strip=True)
        return "FBref Competition"

    def _matches_team_name(self, candidate: str, team_name: str) -> bool:
        return candidate.strip().casefold() == team_name.strip().casefold()

    def _sorted_unique(self, fixtures: List[ScrapedFixture]) -> List[ScrapedFixture]:
        deduped: Dict[str, ScrapedFixture] = {}
        for fixture in fixtures:
            key = "|".join(
                [
                    fixture.competition,
                    fixture.kickoff.isoformat(),
                    fixture.home_team,
                    fixture.away_team,
                ]
            )
            deduped[key] = fixture
        return sorted(deduped.values(), key=lambda item: item.kickoff)

