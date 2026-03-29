import Foundation

enum FavoriteKind: String, Codable, CaseIterable, Sendable {
    case team
    case competition
}

struct FavoriteItem: Codable, Hashable, Identifiable, Sendable {
    let remoteID: Int
    let sourceSlug: String?
    let kind: FavoriteKind
    let name: String
    let subtitle: String?
    let logoURL: URL?
    let season: Int?

    init(
        remoteID: Int,
        sourceSlug: String? = nil,
        kind: FavoriteKind,
        name: String,
        subtitle: String?,
        logoURL: URL?,
        season: Int?
    ) {
        self.remoteID = remoteID
        self.sourceSlug = sourceSlug
        self.kind = kind
        self.name = name
        self.subtitle = subtitle
        self.logoURL = logoURL
        self.season = season
    }

    var id: String {
        if let sourceSlug, sourceSlug.isEmpty == false {
            return "\(kind.rawValue)-\(sourceSlug)"
        }
        return "\(kind.rawValue)-\(remoteID)"
    }

    static func team(from result: TeamSearchResult) -> FavoriteItem {
        FavoriteItem(
            remoteID: result.id,
            sourceSlug: result.sourceSlug,
            kind: .team,
            name: result.name,
            subtitle: result.country,
            logoURL: result.logoURL,
            season: nil
        )
    }

    static func competition(from result: CompetitionSearchResult) -> FavoriteItem {
        FavoriteItem(
            remoteID: result.id,
            sourceSlug: result.sourceSlug,
            kind: .competition,
            name: result.name,
            subtitle: result.country,
            logoURL: result.logoURL,
            season: result.season
        )
    }
}

struct TeamSearchResult: Identifiable, Hashable, Sendable {
    let id: Int
    let sourceSlug: String?
    let name: String
    let country: String
    let logoURL: URL?

    init(id: Int, sourceSlug: String? = nil, name: String, country: String, logoURL: URL?) {
        self.id = id
        self.sourceSlug = sourceSlug
        self.name = name
        self.country = country
        self.logoURL = logoURL
    }
}

struct CompetitionSearchResult: Identifiable, Hashable, Sendable {
    let id: Int
    let sourceSlug: String?
    let name: String
    let country: String
    let logoURL: URL?
    let season: Int?

    init(id: Int, sourceSlug: String? = nil, name: String, country: String, logoURL: URL?, season: Int?) {
        self.id = id
        self.sourceSlug = sourceSlug
        self.name = name
        self.country = country
        self.logoURL = logoURL
        self.season = season
    }
}

struct BroadcastChannel: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let region: String?
}

struct FixtureSummary: Identifiable, Hashable, Sendable {
    let id: Int
    let sourceSlug: String?
    let sourceURL: URL?
    let resultMode: String?
    let competitionName: String
    let kickoff: Date
    let status: String
    let homeTeam: String
    let awayTeam: String
    let venue: String?
    let broadcastChannels: [BroadcastChannel]

    init(
        id: Int,
        sourceSlug: String? = nil,
        sourceURL: URL? = nil,
        resultMode: String? = nil,
        competitionName: String,
        kickoff: Date,
        status: String,
        homeTeam: String,
        awayTeam: String,
        venue: String?,
        broadcastChannels: [BroadcastChannel]
    ) {
        self.id = id
        self.sourceSlug = sourceSlug
        self.sourceURL = sourceURL
        self.resultMode = resultMode
        self.competitionName = competitionName
        self.kickoff = kickoff
        self.status = status
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.venue = venue
        self.broadcastChannels = broadcastChannels
    }

    var matchup: String {
        "\(homeTeam) vs \(awayTeam)"
    }
}

struct TeamStatisticBlock: Identifiable, Hashable, Sendable {
    let teamName: String
    let teamLogoURL: URL?
    let rows: [TeamStatisticRow]

    var id: String {
        teamName
    }
}

struct TeamStatisticRow: Identifiable, Hashable, Sendable {
    let label: String
    let value: String

    var id: String {
        "\(label)-\(value)"
    }
}

struct TeamLineup: Identifiable, Hashable, Sendable {
    let teamName: String
    let formation: String
    let starters: [String]
    let substitutes: [String]

    var id: String {
        teamName
    }
}

struct FixtureDetail: Sendable {
    let summary: FixtureSummary
    let statistics: [TeamStatisticBlock]
    let lineups: [TeamLineup]
    let notes: [String]
}

enum SearchScope: String, CaseIterable, Identifiable {
    case teams = "Teams"
    case competitions = "Competitions"

    var id: String {
        rawValue
    }
}

func stableIdentifier(for rawValue: String) -> Int {
    var hash: UInt64 = 1469598103934665603
    for byte in rawValue.utf8 {
        hash ^= UInt64(byte)
        hash *= 1099511628211
    }
    return Int(hash % UInt64(Int.max))
}
