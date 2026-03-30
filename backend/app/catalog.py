import json
import re
from dataclasses import dataclass
from typing import Dict, List, Optional

from sqlalchemy.orm import Session

from app.models import Source
from app.schemas import SourceUpsertRequest


@dataclass(frozen=True)
class SourceSeed:
    slug: str
    name: str
    source_type: str
    provider: str
    config: Dict[str, object]


SOURCE_SEEDS: List[SourceSeed] = [
    SourceSeed(
        slug="uefa-champions-league",
        name="UEFA Champions League",
        source_type="competition",
        provider="fbref",
        config={
            "mode": "competition_schedule",
            "competition_name": "UEFA Champions League",
            "urls": [
                "https://fbref.com/en/comps/8/schedule/Champions-League-Scores-and-Fixtures",
            ],
        },
    ),
    SourceSeed(
        slug="brazil-serie-b",
        name="Brazil Serie B",
        source_type="competition",
        provider="fbref",
        config={
            "mode": "competition_schedule",
            "competition_name": "Brazil Serie B",
            "urls": [
                "https://fbref.com/en/comps/38/schedule/Serie-B-Scores-and-Fixtures",
            ],
        },
    ),
    SourceSeed(
        slug="crb",
        name="CRB",
        source_type="team",
        provider="fbref",
        config={
            "mode": "team_from_competitions",
            "team_name": "CRB",
            "urls": [
                "https://fbref.com/en/comps/38/schedule/Serie-B-Scores-and-Fixtures",
                "https://fbref.com/en/comps/73/schedule/Copa-do-Brasil-Scores-and-Fixtures",
                "https://fbref.com/en/comps/612/schedule/Copa-do-Nordeste-Scores-and-Fixtures",
            ],
        },
    ),
]


def seed_sources(db: Session) -> None:
    existing = {row.slug for row in db.query(Source.slug).all()}

    for seed in SOURCE_SEEDS:
        if seed.slug in existing:
            continue

        db.add(
            Source(
                slug=seed.slug,
                name=seed.name,
                source_type=seed.source_type,
                provider=seed.provider,
                config_json=json.dumps(seed.config),
            )
        )

    db.commit()


def list_sources(db: Session, query: Optional[str] = None) -> List[Source]:
    statement = db.query(Source).order_by(Source.name.asc())
    if query:
        like = f"%{query.lower()}%"
        statement = statement.filter(Source.name.ilike(like))
    return statement.all()


def get_source(db: Session, slug: str) -> Optional[Source]:
    return db.query(Source).filter(Source.slug == slug).first()


def upsert_source(db: Session, payload: SourceUpsertRequest) -> Source:
    slug = payload.slug or slugify(payload.name)
    source = get_source(db, slug)
    config = build_source_config(payload)
    config_json = json.dumps(config)

    if source is None:
        source = Source(
            slug=slug,
            name=payload.name,
            source_type=payload.source_type,
            provider=payload.provider,
            config_json=config_json,
        )
        db.add(source)
    else:
        source.name = payload.name
        source.source_type = payload.source_type
        source.provider = payload.provider
        source.config_json = config_json

    db.commit()
    db.refresh(source)
    return source


def build_source_config(payload: SourceUpsertRequest) -> Dict[str, object]:
    urls = [str(url) for url in payload.urls]

    if payload.source_type == "competition":
        return {
            "mode": "competition_schedule",
            "competition_name": payload.competition_name or payload.name,
            "urls": urls,
        }

    return {
        "mode": "team_from_competitions",
        "team_name": payload.team_name or payload.name,
        "urls": urls,
    }


def slugify(value: str) -> str:
    normalized = value.strip().casefold()
    normalized = re.sub(r"[^a-z0-9]+", "-", normalized)
    normalized = normalized.strip("-")
    return normalized or "source"

