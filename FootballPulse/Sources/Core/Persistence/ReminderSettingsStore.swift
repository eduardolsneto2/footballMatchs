import Foundation
import Observation

@MainActor
@Observable
final class ReminderSettingsStore {
    private enum Keys {
        static let remindersEnabled = "footballpulse.reminders.enabled"
        static let leadTimeMinutes = "footballpulse.reminders.leadTimeMinutes"
    }

    private let userDefaults: UserDefaults

    var remindersEnabled: Bool {
        didSet {
            userDefaults.set(remindersEnabled, forKey: Keys.remindersEnabled)
        }
    }

    var leadTimeMinutes: Int {
        didSet {
            userDefaults.set(leadTimeMinutes, forKey: Keys.leadTimeMinutes)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if userDefaults.object(forKey: Keys.remindersEnabled) == nil {
            remindersEnabled = true
        } else {
            remindersEnabled = userDefaults.bool(forKey: Keys.remindersEnabled)
        }

        let storedLeadTime = userDefaults.integer(forKey: Keys.leadTimeMinutes)
        leadTimeMinutes = storedLeadTime == 0 ? 30 : storedLeadTime
    }
}
