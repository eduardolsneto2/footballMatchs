import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
