import SwiftUI

struct DiscoverView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Scope", selection: $viewModel.scope) {
                        ForEach(SearchScope.allCases) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Search teams or competitions", text: $viewModel.query)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                await viewModel.search(using: environment.apiService)
                            }
                        }

                    Button {
                        Task {
                            await viewModel.search(using: environment.apiService)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Search")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                switch viewModel.scope {
                case .teams:
                    resultsSectionForTeams
                case .competitions:
                    resultsSectionForCompetitions
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Discover")
        }
    }

    private var resultsSectionForTeams: some View {
        Section("Results") {
            if viewModel.teamResults.isEmpty {
                if viewModel.query.isEmpty == false && viewModel.isLoading == false {
                    Text("No teams found for that search yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(viewModel.teamResults) { team in
                    HStack(spacing: 12) {
                        AsyncImage(url: team.logoURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "shield")
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .font(.headline)
                            Text(team.country)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        let favorite = FavoriteItem.team(from: team)
                        Button(environment.favoritesStore.isFavorite(favorite) ? "Saved" : "Favorite") {
                            environment.favoritesStore.toggle(favorite)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    private var resultsSectionForCompetitions: some View {
        Section("Results") {
            if viewModel.competitionResults.isEmpty {
                if viewModel.query.isEmpty == false && viewModel.isLoading == false {
                    Text("No competitions found for that search yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(viewModel.competitionResults) { competition in
                    HStack(spacing: 12) {
                        AsyncImage(url: competition.logoURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "trophy")
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(competition.name)
                                .font(.headline)
                            Text(competition.country)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        let favorite = FavoriteItem.competition(from: competition)
                        Button(environment.favoritesStore.isFavorite(favorite) ? "Saved" : "Favorite") {
                            environment.favoritesStore.toggle(favorite)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
