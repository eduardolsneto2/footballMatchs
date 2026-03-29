import XCTest
@testable import FootballPulse

@MainActor
final class FavoritesStoreTests: XCTestCase {
    func testToggleAddsAndRemovesFavorite() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let store = FavoritesStore(userDefaults: defaults, storageKey: #function)
        let favorite = FavoriteItem(
            remoteID: 33,
            kind: .team,
            name: "Manchester United",
            subtitle: "England",
            logoURL: nil,
            season: nil
        )

        store.toggle(favorite)
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertTrue(store.isFavorite(favorite))

        let reloaded = FavoritesStore(userDefaults: defaults, storageKey: #function)
        XCTAssertEqual(reloaded.favorites.count, 1)

        reloaded.toggle(favorite)
        XCTAssertTrue(reloaded.favorites.isEmpty)
    }
}
