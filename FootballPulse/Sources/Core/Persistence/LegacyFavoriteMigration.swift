import Foundation

/// Maps display names from older favorites (saved before `sourceSlug` existed) to backend `sources.slug`
/// values. Keep in sync with `backend/app/catalog.py` `SOURCE_SEEDS`.
enum LegacyFavoriteMigration {
    private static let slugByNormalizedName: [String: String] = [
        "crb": "crb",
        "uefa champions league": "uefa-champions-league",
        "brazil serie b": "brazil-serie-b"
    ]

    static func sourceSlugIfMissing(for favorite: FavoriteItem) -> String? {
        if let slug = favorite.sourceSlug, slug.isEmpty == false {
            return nil
        }
        let key = favorite.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return slugByNormalizedName[key]
    }

    static func migrated(_ favorite: FavoriteItem) -> FavoriteItem {
        guard let slug = sourceSlugIfMissing(for: favorite) else {
            return favorite
        }
        return FavoriteItem(
            remoteID: favorite.remoteID,
            sourceSlug: slug,
            kind: favorite.kind,
            name: favorite.name,
            subtitle: favorite.subtitle,
            logoURL: favorite.logoURL,
            season: favorite.season
        )
    }
}
