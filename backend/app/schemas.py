from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class SourceResponse(BaseModel):
    slug: str
    name: str
    source_type: str
    provider: str


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

