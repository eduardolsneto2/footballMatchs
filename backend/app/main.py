from datetime import datetime, timedelta
from typing import Optional

from fastapi import Depends, FastAPI, HTTPException, Query
from sqlalchemy.orm import Session

from app.catalog import get_source, list_sources, seed_sources
from app.config import get_settings
from app.database import Base, SessionLocal, engine, get_db
from app.models import FixtureCache
from app.schemas import FixtureListResponse, FixtureResponse, SourceResponse
from app.services.fbref import FBrefScraper


settings = get_settings()
app = FastAPI(title=settings.app_name)
scraper = FBrefScraper()


@app.on_event("startup")
def startup() -> None:
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        seed_sources(db)


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "app": settings.app_name}


@app.get("/api/v1/sources", response_model=list[SourceResponse])
def sources(
    q: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    return [
        SourceResponse(
            slug=source.slug,
            name=source.name,
            source_type=source.source_type,
            provider=source.provider,
        )
        for source in list_sources(db, q)
    ]


@app.get("/api/v1/fixtures/{source_slug}", response_model=FixtureListResponse)
async def fixtures(
    source_slug: str,
    refresh: bool = Query(default=False),
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    source = get_source(db, source_slug)
    if source is None:
        raise HTTPException(status_code=404, detail="Source not found")

    cached_rows = (
        db.query(FixtureCache)
        .filter(FixtureCache.source_slug == source_slug)
        .order_by(FixtureCache.kickoff.asc())
        .all()
    )

    cache_is_fresh = False
    if cached_rows:
        newest_fetch = max(row.fetched_at for row in cached_rows)
        cache_is_fresh = newest_fetch >= datetime.utcnow() - timedelta(minutes=settings.cache_ttl_minutes)

    if refresh or not cache_is_fresh:
        scraped = await scraper.scrape(source.config_json)
        fetched_at = datetime.utcnow()

        db.query(FixtureCache).filter(FixtureCache.source_slug == source_slug).delete()
        for fixture in scraped:
            db.add(
                FixtureCache(
                    source_slug=source_slug,
                    competition=fixture.competition,
                    kickoff=fixture.kickoff,
                    home_team=fixture.home_team,
                    away_team=fixture.away_team,
                    status=fixture.status,
                    score=fixture.score,
                    venue=fixture.venue,
                    source_url=fixture.source_url,
                    fetched_at=fetched_at,
                )
            )
        db.commit()

        cached_rows = (
            db.query(FixtureCache)
            .filter(FixtureCache.source_slug == source_slug)
            .order_by(FixtureCache.kickoff.asc())
            .all()
        )

    mode = "upcoming"
    upcoming = [row for row in cached_rows if row.kickoff >= datetime.utcnow()]
    selected = upcoming[:limit]

    if not selected:
        mode = "recent"
        selected = list(reversed(cached_rows[-limit:]))

    fetched_at = max((row.fetched_at for row in cached_rows), default=datetime.utcnow())

    return FixtureListResponse(
        source=SourceResponse(
            slug=source.slug,
            name=source.name,
            source_type=source.source_type,
            provider=source.provider,
        ),
        mode=mode,
        fixtures=[
            FixtureResponse(
                competition=row.competition,
                kickoff=row.kickoff,
                home_team=row.home_team,
                away_team=row.away_team,
                status=row.status,
                score=row.score,
                venue=row.venue,
                source_url=row.source_url,
            )
            for row in selected
        ],
        fetched_at=fetched_at,
    )

