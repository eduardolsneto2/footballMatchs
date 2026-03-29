import Foundation
import Observation

@MainActor
@Observable
final class FixtureDetailViewModel {
    var detail: FixtureDetail?
    var isLoading = false
    var errorMessage: String?

    func load(fixtureID: Int, using service: any APIFootballService) async {
        isLoading = true
        defer { isLoading = false }

        do {
            detail = try await service.fixtureDetails(id: fixtureID)
            errorMessage = nil
        } catch {
            detail = nil
            errorMessage = error.localizedDescription
        }
    }
}
