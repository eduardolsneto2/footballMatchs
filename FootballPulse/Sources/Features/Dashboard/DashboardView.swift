import SwiftUI

struct DashboardView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel = DashboardViewModel()
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            List {
                if environment.dataSourceMode == .mockData {
                    Section {
                        Text("Running in mock mode until a valid backend URL is available.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if environment.favoritesStore.favorites.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No favorites yet",
                            systemImage: "star",
                            description: Text("Favorite a team or competition in Discover to pin matches here.")
                        )
                    }
                } else {
                    ForEach(viewModel.sections) { section in
                        Section(section.favorite.name) {
                            if let errorMessage = section.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } else if section.fixtures.isEmpty {
                                Text("No fixtures are available for this source yet.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(section.fixtures) { fixture in
                                    NavigationLink(value: fixture) {
                                        FixtureRowView(fixture: fixture)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button("Remind") {
                                            Task {
                                                await scheduleReminder(for: fixture)
                                            }
                                        }
                                        .tint(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("FootballPulse")
            .navigationDestination(for: FixtureSummary.self) { fixture in
                FixtureDetailView(fixtureID: fixture.id)
            }
            .task {
                await reload()
            }
            .refreshable {
                await reload()
            }
            .onChange(of: environment.favoritesStore.favoritesSignature) { _, _ in
                Task {
                    await reload()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading matches...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .alert("Reminder", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func reload() async {
        await viewModel.load(favorites: environment.favoritesStore.favorites, using: environment.apiService)
    }

    private func scheduleReminder(for fixture: FixtureSummary) async {
        guard environment.reminderSettings.remindersEnabled else {
            alertMessage = "Enable reminders in Settings before scheduling match alerts."
            showingAlert = true
            return
        }

        let status = environment.notificationManager.authorizationStatus
        if status != .authorized && status != .provisional {
            let granted = await environment.notificationManager.requestAuthorization()
            guard granted else {
                alertMessage = "Notification permission was not granted."
                showingAlert = true
                return
            }
        }

        do {
            try await environment.notificationManager.scheduleReminder(
                for: fixture,
                leadTimeMinutes: environment.reminderSettings.leadTimeMinutes
            )
            alertMessage = "Reminder scheduled \(environment.reminderSettings.leadTimeMinutes) minutes before kickoff."
        } catch {
            alertMessage = error.localizedDescription
        }

        showingAlert = true
    }
}
