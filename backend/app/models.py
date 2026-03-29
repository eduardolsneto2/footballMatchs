from datetime import datetime

from sqlalchemy import DateTime, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Source(Base):
    __tablename__ = "sources"

    slug: Mapped[str] = mapped_column(String(100), primary_key=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    source_type: Mapped[str] = mapped_column(String(50), nullable=False)
    provider: Mapped[str] = mapped_column(String(50), nullable=False)
    config_json: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)


class FixtureCache(Base):
    __tablename__ = "fixture_cache"
    __table_args__ = (
        UniqueConstraint("source_slug", "kickoff", "home_team", "away_team", name="uq_fixture_cache_identity"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    source_slug: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    competition: Mapped[str] = mapped_column(String(200), nullable=False)
    kickoff: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    home_team: Mapped[str] = mapped_column(String(200), nullable=False)
    away_team: Mapped[str] = mapped_column(String(200), nullable=False)
    status: Mapped[str] = mapped_column(String(50), nullable=False)
    score: Mapped[str] = mapped_column(String(50), nullable=True)
    venue: Mapped[str] = mapped_column(String(200), nullable=True)
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False, index=True)

