import XCTest
@testable import FootballPulse

@MainActor
final class ReminderSettingsStoreTests: XCTestCase {
    func testReminderSettingsPersistChanges() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let store = ReminderSettingsStore(userDefaults: defaults)
        XCTAssertTrue(store.remindersEnabled)
        XCTAssertEqual(store.leadTimeMinutes, 30)

        store.remindersEnabled = false
        store.leadTimeMinutes = 45

        let reloaded = ReminderSettingsStore(userDefaults: defaults)
        XCTAssertFalse(reloaded.remindersEnabled)
        XCTAssertEqual(reloaded.leadTimeMinutes, 45)
    }
}
