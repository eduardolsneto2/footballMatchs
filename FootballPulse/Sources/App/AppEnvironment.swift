import Foundation
import Observation

@MainActor
@Observable
final class AppEnvironment {
    let apiService: any APIFootballService
    let favoritesStore: FavoritesStore
    let reminderSettings: ReminderSettingsStore
    let notificationManager: NotificationManager
    let dataSourceMode: DataSourceMode
    let configurationSummary: String

    init(
        apiService: any APIFootballService,
        favoritesStore: FavoritesStore,
        reminderSettings: ReminderSettingsStore,
        notificationManager: NotificationManager,
        dataSourceMode: DataSourceMode,
        configurationSummary: String
    ) {
        self.apiService = apiService
        self.favoritesStore = favoritesStore
        self.reminderSettings = reminderSettings
        self.notificationManager = notificationManager
        self.dataSourceMode = dataSourceMode
        self.configurationSummary = configurationSummary
    }

    static func bootstrap() -> AppEnvironment {
        let favoritesStore = FavoritesStore()
        let reminderSettings = ReminderSettingsStore()
        let notificationManager = NotificationManager()

        if let configuration = BackendConfiguration.fromBundle() {
            return AppEnvironment(
                apiService: BackendFootballService(configuration: configuration),
                favoritesStore: favoritesStore,
                reminderSettings: reminderSettings,
                notificationManager: notificationManager,
                dataSourceMode: .liveAPI,
                configurationSummary: configuration.baseURL.absoluteString
            )
        }

        return AppEnvironment(
            apiService: MockAPIFootballService(),
            favoritesStore: favoritesStore,
            reminderSettings: reminderSettings,
            notificationManager: notificationManager,
            dataSourceMode: .mockData,
            configurationSummary: "Mock mode"
        )
    }
}

enum DataSourceMode: String {
    case liveAPI = "Backend"
    case mockData = "Mock Data"
}
