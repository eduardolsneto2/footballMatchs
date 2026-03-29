import SwiftUI

struct FixtureDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel = FixtureDetailViewModel()

    let fixtureID: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let detail = viewModel.detail {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(detail.summary.matchup)
                            .font(.title2.weight(.bold))

                        Label(detail.summary.competitionName, systemImage: "trophy")
                            .foregroundStyle(.secondary)

                        Label(detail.summary.kickoff.formatted(date: .complete, time: .shortened), systemImage: "calendar")
                            .foregroundStyle(.secondary)

                        if let venue = detail.summary.venue, venue.isEmpty == false {
                            Label(venue, systemImage: "mappin.and.ellipse")
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Where to watch")
                            .font(.headline)

                        if detail.summary.broadcastChannels.isEmpty {
                            Text("Broadcast details are not available for this fixture yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(detail.summary.broadcastChannels) { channel in
                                Text(channel.region.map { "\(channel.name) - \($0)" } ?? channel.name)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stats")
                            .font(.headline)

                        if detail.statistics.isEmpty {
                            Text("Statistics will appear here when the API provides them for the fixture.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(detail.statistics) { block in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(block.teamName)
                                        .font(.subheadline.weight(.semibold))

                                    ForEach(block.rows) { row in
                                        HStack {
                                            Text(row.label)
                                            Spacer()
                                            Text(row.value)
                                                .foregroundStyle(.secondary)
                                        }
                                        .font(.footnote)
                                    }
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lineups")
                            .font(.headline)

                        if detail.lineups.isEmpty {
                            Text("Lineups will appear closer to kickoff when the provider has them.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(detail.lineups) { lineup in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(lineup.teamName) - \(lineup.formation)")
                                        .font(.subheadline.weight(.semibold))

                                    Text("Starters: \(lineup.starters.joined(separator: ", "))")
                                        .font(.footnote)

                                    Text("Bench: \(lineup.substitutes.joined(separator: ", "))")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Implementation notes")
                            .font(.headline)

                        ForEach(detail.notes, id: \.self) { note in
                            Text(note)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to load fixture",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    ProgressView("Loading fixture...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                }
            }
            .padding()
        }
        .navigationTitle("Match Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(fixtureID: fixtureID, using: environment.apiService)
        }
    }
}
