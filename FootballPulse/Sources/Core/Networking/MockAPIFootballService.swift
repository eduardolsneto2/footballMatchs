import Foundation

struct MockAPIFootballService: APIFootballService {
    func searchTeams(query: String) async throws -> [TeamSearchResult] {
        let allTeams = [
            TeamSearchResult(id: 33, name: "Manchester United", country: "England", logoURL: nil),
            TeamSearchResult(id: 541, name: "Real Madrid", country: "Spain", logoURL: nil),
            TeamSearchResult(id: 85, name: "Paris Saint Germain", country: "France", logoURL: nil),
            TeamSearchResult(id: 489, name: "AC Milan", country: "Italy", logoURL: nil)
        ]

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return allTeams }
        return allTeams.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    func searchCompetitions(query: String) async throws -> [CompetitionSearchResult] {
        let allCompetitions = [
            CompetitionSearchResult(id: 39, name: "Premier League", country: "England", logoURL: nil, season: 2026),
            CompetitionSearchResult(id: 140, name: "La Liga", country: "Spain", logoURL: nil, season: 2026),
            CompetitionSearchResult(id: 61, name: "Ligue 1", country: "France", logoURL: nil, season: 2026),
            CompetitionSearchResult(id: 2, name: "UEFA Champions League", country: "Europe", logoURL: nil, season: 2026)
        ]

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return allCompetitions }
        return allCompetitions.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    func upcomingFixtures(for favorite: FavoriteItem, limit: Int) async throws -> [FixtureSummary] {
        let base = Date.now
        let fixtures = [
            FixtureSummary(
                id: 1001 + favorite.remoteID,
                competitionName: favorite.kind == .team ? "League Match" : favorite.name,
                kickoff: Calendar.current.date(byAdding: .hour, value: 20, to: base) ?? base,
                status: "NS",
                homeTeam: favorite.kind == .team ? favorite.name : "Featured Home Team",
                awayTeam: favorite.kind == .team ? "Rival FC" : "Featured Away Team",
                venue: "National Stadium",
                broadcastChannels: [BroadcastChannel(id: "espn", name: "ESPN", region: "Global")]
            ),
            FixtureSummary(
                id: 2001 + favorite.remoteID,
                competitionName: favorite.kind == .team ? "Cup Match" : favorite.name,
                kickoff: Calendar.current.date(byAdding: .day, value: 3, to: base) ?? base,
                status: "NS",
                homeTeam: favorite.kind == .team ? "Away United" : "Second Home Team",
                awayTeam: favorite.kind == .team ? favorite.name : "Second Away Team",
                venue: "City Arena",
                broadcastChannels: []
            )
        ]

        return Array(fixtures.prefix(limit))
    }

    func fixtureDetails(id: Int) async throws -> FixtureDetail {
        let summary = FixtureSummary(
            id: id,
            competitionName: "Mock Competition",
            kickoff: Calendar.current.date(byAdding: .hour, value: 12, to: .now) ?? .now,
            status: "NS",
            homeTeam: "Mock Home",
            awayTeam: "Mock Away",
            venue: "Preview Stadium",
            broadcastChannels: [BroadcastChannel(id: "espn", name: "ESPN", region: "Global")]
        )

        let statistics = [
            TeamStatisticBlock(
                teamName: "Mock Home",
                teamLogoURL: nil,
                rows: [
                    TeamStatisticRow(label: "Ball Possession", value: "54%"),
                    TeamStatisticRow(label: "Shots on Goal", value: "7")
                ]
            ),
            TeamStatisticBlock(
                teamName: "Mock Away",
                teamLogoURL: nil,
                rows: [
                    TeamStatisticRow(label: "Ball Possession", value: "46%"),
                    TeamStatisticRow(label: "Shots on Goal", value: "4")
                ]
            )
        ]

        let lineups = [
            TeamLineup(teamName: "Mock Home", formation: "4-3-3", starters: ["Player A", "Player B", "Player C"], substitutes: ["Player D", "Player E"]),
            TeamLineup(teamName: "Mock Away", formation: "4-2-3-1", starters: ["Player F", "Player G", "Player H"], substitutes: ["Player I", "Player J"])
        ]

        return FixtureDetail(
            summary: summary,
            statistics: statistics,
            lineups: lineups,
            notes: [
                "This fixture is coming from mock data because no API key is configured yet.",
                "Remote push notifications should eventually be triggered by your backend, not by the app directly."
            ]
        )
    }
}
