from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    app_name: str
    environment: str
    database_url: str
    scrape_timeout_seconds: float
    cache_ttl_minutes: int


def get_settings() -> Settings:
    return Settings(
        app_name=os.getenv("APP_NAME", "FootballPulse Scraper API"),
        environment=os.getenv("APP_ENV", "development"),
        database_url=os.getenv("DATABASE_URL", "sqlite:///./footballpulse_scraper.db"),
        scrape_timeout_seconds=float(os.getenv("SCRAPE_TIMEOUT_SECONDS", "20")),
        cache_ttl_minutes=int(os.getenv("CACHE_TTL_MINUTES", "360")),
    )

