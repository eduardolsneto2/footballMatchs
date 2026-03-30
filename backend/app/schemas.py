from datetime import datetime
from typing import List, Literal, Optional

from pydantic import BaseModel, HttpUrl, field_validator


class SourceResponse(BaseModel):
    slug: str
    name: str
    source_type: str
    provider: str


class SourceUpsertRequest(BaseModel):
    slug: Optional[str] = None
    name: str
    source_type: Literal["team", "competition"]
    provider: Literal["fbref"] = "fbref"
    urls: List[HttpUrl]
    team_name: Optional[str] = None
    competition_name: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("name must not be empty")
        return normalized

    @field_validator("slug")
    @classmethod
    def validate_slug(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        normalized = value.strip()
        return normalized or None

    @field_validator("urls")
    @classmethod
    def validate_urls(cls, value: List[HttpUrl]) -> List[HttpUrl]:
        if not value:
            raise ValueError("urls must contain at least one FBref page")
        return value

    @field_validator("team_name")
    @classmethod
    def validate_team_name(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        normalized = value.strip()
        return normalized or None

    @field_validator("competition_name")
    @classmethod
    def validate_competition_name(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        normalized = value.strip()
        return normalized or None


class FixtureResponse(BaseModel):
    competition: str
    kickoff: datetime
    home_team: str
    away_team: str
    status: str
    score: Optional[str]
    venue: Optional[str]
    source_url: str


class FixtureListResponse(BaseModel):
    source: SourceResponse
    mode: str
    fixtures: List[FixtureResponse]
    fetched_at: datetime

