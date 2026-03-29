import Foundation
import Observation

@MainActor
@Observable
final class DiscoverViewModel {
    var query = ""
    var scope: SearchScope = .teams
    var teamResults: [TeamSearchResult] = []
    var competitionResults: [CompetitionSearchResult] = []
    var isLoading = false
    var errorMessage: String?

    func search(using service: any APIFootballService) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            teamResults = []
            competitionResults = []
            errorMessage = nil
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            switch scope {
            case .teams:
                teamResults = try await service.searchTeams(query: trimmedQuery)
                competitionResults = []
            case .competitions:
                competitionResults = try await service.searchCompetitions(query: trimmedQuery)
                teamResults = []
            }
        } catch {
            errorMessage = error.localizedDescription
            teamResults = []
            competitionResults = []
        }
    }
}
