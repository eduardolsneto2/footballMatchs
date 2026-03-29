import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class NotificationManager {
    private let center: UNUserNotificationCenter
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center

        Task {
            await refreshAuthorizationStatus()
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        await refreshAuthorizationStatus()
        return granted
    }

    func scheduleReminder(for fixture: FixtureSummary, leadTimeMinutes: Int) async throws {
        let reminderDate = fixture.kickoff.addingTimeInterval(TimeInterval(-leadTimeMinutes * 60))
        guard reminderDate > .now else {
            throw NotificationError.kickoffTooSoon
        }

        let content = UNMutableNotificationContent()
        content.title = fixture.matchup
        content.subtitle = "Kickoff in \(leadTimeMinutes) minutes"
        content.body = "\(fixture.competitionName) starts at \(fixture.kickoff.formatted(date: .omitted, time: .shortened))."
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier(for: fixture.id), content: content, trigger: trigger)

        try await center.add(request)
    }

    func removeReminder(for fixtureID: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: fixtureID)])
    }

    private static func identifier(for fixtureID: Int) -> String {
        "footballpulse.fixture.reminder.\(fixtureID)"
    }
}

enum NotificationError: LocalizedError {
    case kickoffTooSoon

    var errorDescription: String? {
        switch self {
        case .kickoffTooSoon:
            return "This kickoff is too close to schedule a reminder with the selected lead time."
        }
    }
}

extension UNAuthorizationStatus {
    var displayText: String {
        switch self {
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .ephemeral:
            return "Ephemeral"
        case .notDetermined:
            return "Not Determined"
        case .provisional:
            return "Provisional"
        @unknown default:
            return "Unknown"
        }
    }
}
