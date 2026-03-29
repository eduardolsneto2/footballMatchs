import Foundation
import Observation

@MainActor
@Observable
final class FavoritesStore {
    private let userDefaults: UserDefaults
    private let storageKey: String
    private(set) var favorites: [FavoriteItem]

    init(userDefaults: UserDefaults = .standard, storageKey: String = "footballpulse.favorites") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.favorites = Self.loadFavorites(from: userDefaults, storageKey: storageKey)
    }

    var favoritesSignature: String {
        favorites.map(\.id).sorted().joined(separator: "|")
    }

    func toggle(_ favorite: FavoriteItem) {
        if isFavorite(favorite) {
            favorites.removeAll { $0.id == favorite.id }
        } else {
            favorites.append(favorite)
        }
        favorites.sort { $0.name < $1.name }
        persist()
    }

    func remove(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
        persist()
    }

    func isFavorite(_ favorite: FavoriteItem) -> Bool {
        favorites.contains(where: { $0.id == favorite.id })
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: storageKey)
        }
    }

    private static func loadFavorites(from defaults: UserDefaults, storageKey: String) -> [FavoriteItem] {
        guard
            let data = defaults.data(forKey: storageKey),
            let favorites = try? JSONDecoder().decode([FavoriteItem].self, from: data)
        else {
            return []
        }

        return favorites.sorted { $0.name < $1.name }
    }
}
