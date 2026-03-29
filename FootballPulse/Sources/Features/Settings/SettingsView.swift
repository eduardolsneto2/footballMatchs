import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var permissionMessage = ""
    @State private var showingPermissionAlert = false

    var body: some View {
        @Bindable var reminderSettings = environment.reminderSettings

        NavigationStack {
            Form {
                Section("Data Source") {
                    LabeledContent("Mode", value: environment.dataSourceMode.rawValue)
                    LabeledContent("Target", value: environment.configurationSummary)

                    if environment.dataSourceMode == .mockData {
                        Text("Set `BACKEND_BASE_URL` in `Config/Secrets.xcconfig` if you want to override the local backend address.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notifications") {
                    Toggle("Enable match reminders", isOn: $reminderSettings.remindersEnabled)

                    Stepper(value: $reminderSettings.leadTimeMinutes, in: 5 ... 180, step: 5) {
                        Text("Notify \(reminderSettings.leadTimeMinutes) minutes before kickoff")
                    }

                    LabeledContent("Authorization", value: environment.notificationManager.authorizationStatus.displayText)

                    Button("Request Notification Access") {
                        Task {
                            let granted = await environment.notificationManager.requestAuthorization()
                            permissionMessage = granted ? "Notification access granted." : "Notification access was not granted."
                            showingPermissionAlert = true
                        }
                    }
                }

                Section("Go Live Checklist") {
                    Text("Use a production backend URL and a durable database before App Store release.")
                    Text("Add branded app icons, a final bundle identifier, privacy labels, screenshots, and App Store metadata.")
                    Text("Remote push notifications will require a backend job or webhook that tracks fixture changes and talks to APNs.")
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .alert("Notifications", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(permissionMessage)
            }
        }
    }
}
