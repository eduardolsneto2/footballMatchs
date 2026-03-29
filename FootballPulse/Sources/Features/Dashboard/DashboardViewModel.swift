import Foundation
import Observation

struct FavoriteFixtureSection: Identifiable {
    let favorite: FavoriteItem
    let fixtures: [FixtureSummary]
    let errorMessage: String?

    var id: String {
        favorite.id
    }
}

@MainActor
@Observable
final class DashboardViewModel {
    var sections: [FavoriteFixtureSection] = []
    var isLoading = false

    func load(favorites: [FavoriteItem], using service: any APIFootballService) async {
        isLoading = true
        defer { isLoading = false }

        guard favorites.isEmpty == false else {
            sections = []
            return
        }

        var nextSections: [FavoriteFixtureSection] = []

        for favorite in favorites {
            do {
                let fixtures = try await service.upcomingFixtures(for: favorite, limit: 10)
                nextSections.append(FavoriteFixtureSection(favorite: favorite, fixtures: fixtures, errorMessage: nil))
            } catch {
                nextSections.append(
                    FavoriteFixtureSection(
                        favorite: favorite,
                        fixtures: [],
                        errorMessage: error.localizedDescription
                    )
                )
            }
        }

        sections = nextSections.sorted { $0.favorite.name < $1.favorite.name }
    }
}
