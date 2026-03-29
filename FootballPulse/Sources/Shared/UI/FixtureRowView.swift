import SwiftUI

struct FixtureRowView: View {
    let fixture: FixtureSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fixture.competitionName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(fixture.matchup)
                .font(.headline)

            HStack {
                Label(fixture.kickoff.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                Spacer()
                Text(fixture.status)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let venue = fixture.venue, venue.isEmpty == false {
                Label(venue, systemImage: "mappin.and.ellipse")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if fixture.broadcastChannels.isEmpty == false {
                Label(
                    fixture.broadcastChannels.map(\.name).joined(separator: ", "),
                    systemImage: "tv"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
