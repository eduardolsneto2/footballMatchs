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

    func testLegacyFavoriteWithoutSourceSlugIsMigratedForKnownBackendSeed() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let storageKey = "footballpulse.favorites.migration.test"

        let legacyJSON = """
        [{"remoteID":999999,"kind":"team","name":"CRB","subtitle":"FBREF","logoURL":null,"season":null}]
        """.data(using: .utf8)!
        defaults.set(legacyJSON, forKey: storageKey)

        let store = FavoritesStore(userDefaults: defaults, storageKey: storageKey)
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertEqual(store.favorites.first?.sourceSlug, "crb")
        XCTAssertEqual(store.favorites.first?.id, "team-crb")

        let reloaded = FavoritesStore(userDefaults: defaults, storageKey: storageKey)
        XCTAssertEqual(reloaded.favorites.first?.sourceSlug, "crb")
    }
}
