import SwiftUI

struct FavoritesView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        NavigationStack {
            List {
                if environment.favoritesStore.favorites.isEmpty {
                    ContentUnavailableView(
                        "No favorites saved",
                        systemImage: "star.slash",
                        description: Text("Use Discover to save teams and competitions for the home dashboard.")
                    )
                } else {
                    ForEach(environment.favoritesStore.favorites) { favorite in
                        HStack(spacing: 12) {
                            AsyncImage(url: favorite.logoURL) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Image(systemName: favorite.kind == .team ? "shield" : "trophy")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 28, height: 28)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(favorite.name)
                                    .font(.headline)
                                Text(favorite.subtitle ?? favorite.kind.rawValue.capitalized)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(favorite.kind == .team ? "Team" : "Competition")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }
                    .onDelete(perform: environment.favoritesStore.remove)
                }
            }
            .navigationTitle("Favorites")
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
    }
}
