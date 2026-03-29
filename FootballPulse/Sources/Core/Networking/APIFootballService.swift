import Foundation

protocol APIFootballService: Sendable {
    func searchTeams(query: String) async throws -> [TeamSearchResult]
    func searchCompetitions(query: String) async throws -> [CompetitionSearchResult]
    func upcomingFixtures(for favorite: FavoriteItem, limit: Int) async throws -> [FixtureSummary]
    func fixtureDetails(id: Int) async throws -> FixtureDetail
}
