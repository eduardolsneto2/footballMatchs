import SwiftUI

/// Custom root navigation instead of `TabView`.
/// On iOS 26, system `TabView` can inset content in a rounded “card” (Liquid Glass) regardless of plist flags;
/// hosting each screen in a `ZStack` plus a `safeAreaInset` tab strip keeps the UI edge-to-edge on all versions.
struct RootTabView: View {
    private enum MainTab: Int, CaseIterable {
        case home
        case discover
        case favorites
        case settings

        var title: String {
            switch self {
            case .home: "Home"
            case .discover: "Discover"
            case .favorites: "Favorites"
            case .settings: "Settings"
            }
        }

        var systemImage: String {
            switch self {
            case .home: "house"
            case .discover: "magnifyingglass"
            case .favorites: "star"
            case .settings: "gearshape"
            }
        }
    }

    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack {
            DashboardView()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            DiscoverView()
                .opacity(selectedTab == .discover ? 1 : 0)
                .allowsHitTesting(selectedTab == .discover)
                .accessibilityHidden(selectedTab != .discover)

            FavoritesView()
                .opacity(selectedTab == .favorites ? 1 : 0)
                .allowsHitTesting(selectedTab == .favorites)
                .accessibilityHidden(selectedTab != .favorites)

            SettingsView()
                .opacity(selectedTab == .settings ? 1 : 0)
                .allowsHitTesting(selectedTab == .settings)
                .accessibilityHidden(selectedTab != .settings)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedTab == tab ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
