import json

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.catalog import build_source_config, slugify, upsert_source
from app.database import Base
from app.schemas import SourceUpsertRequest


def build_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    return sessionmaker(bind=engine)()


def test_upsert_source_creates_team_source_with_generated_slug():
    db = build_session()
    payload = SourceUpsertRequest(
        name="Arsenal",
        source_type="team",
        urls=[
            "https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures",
            "https://fbref.com/en/comps/8/schedule/Champions-League-Scores-and-Fixtures",
        ],
    )

    source = upsert_source(db, payload)
    config = json.loads(source.config_json)

    assert source.slug == "arsenal"
    assert source.source_type == "team"
    assert config["mode"] == "team_from_competitions"
    assert config["team_name"] == "Arsenal"
    assert len(config["urls"]) == 2


def test_build_source_config_for_competition_uses_competition_mode():
    payload = SourceUpsertRequest(
        name="Premier League",
        source_type="competition",
        competition_name="Premier League",
        urls=["https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures"],
    )

    config = build_source_config(payload)

    assert config == {
        "mode": "competition_schedule",
        "competition_name": "Premier League",
        "urls": ["https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures"],
    }


def test_slugify_normalizes_names():
    assert slugify("UEFA Champions League") == "uefa-champions-league"
    assert slugify("  CRB / Serie B  ") == "crb-serie-b"
