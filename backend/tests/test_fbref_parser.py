from app.services.fbref import FBrefScraper


def test_parse_schedule_html_from_comment_wrapped_table():
    html = """
    <html>
      <body>
        <h1>2024-2025 Champions League Scores & Fixtures</h1>
        <!--
        <table>
          <thead>
            <tr>
              <th data-stat="date">Date</th>
              <th data-stat="start_time">Time</th>
              <th data-stat="home_team">Home</th>
              <th data-stat="score">Score</th>
              <th data-stat="away_team">Away</th>
              <th data-stat="venue">Venue</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td data-stat="date">2025-05-31</td>
              <td data-stat="start_time">19:00</td>
              <td data-stat="home_team">Paris Saint Germain</td>
              <td data-stat="score">5-0</td>
              <td data-stat="away_team">Inter</td>
              <td data-stat="venue">Allianz Arena</td>
            </tr>
          </tbody>
        </table>
        -->
      </body>
    </html>
    """

    fixtures = FBrefScraper().parse_schedule_html(
        html,
        source_url="https://fbref.com/en/comps/8/schedule/Champions-League-Scores-and-Fixtures",
        override_competition_name="UEFA Champions League",
    )

    assert len(fixtures) == 1
    fixture = fixtures[0]
    assert fixture.home_team == "Paris Saint Germain"
    assert fixture.away_team == "Inter"
    assert fixture.score == "5-0"
    assert fixture.venue == "Allianz Arena"

