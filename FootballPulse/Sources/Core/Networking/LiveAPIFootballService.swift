import Foundation

actor BackendFootballService: APIFootballService {
    private let configuration: BackendConfiguration
    private var fixtureCache: [Int: FixtureSummary] = [:]

    init(configuration: BackendConfiguration) {
        self.configuration = configuration
    }

    func searchTeams(query: String) async throws -> [TeamSearchResult] {
        let payload: [BackendSourceDTO] = try await request(
            path: "/api/v1/sources",
            queryItems: [URLQueryItem(name: "q", value: query)]
        )

        return payload
            .filter { $0.sourceType == "team" }
            .map {
                TeamSearchResult(
                    id: stableIdentifier(for: $0.slug),
                    sourceSlug: $0.slug,
                    name: $0.name,
                    country: $0.provider.uppercased(),
                    logoURL: nil
                )
            }
    }

    func searchCompetitions(query: String) async throws -> [CompetitionSearchResult] {
        let payload: [BackendSourceDTO] = try await request(
            path: "/api/v1/sources",
            queryItems: [URLQueryItem(name: "q", value: query)]
        )

        return payload
            .filter { $0.sourceType == "competition" }
            .map {
                CompetitionSearchResult(
                    id: stableIdentifier(for: $0.slug),
                    sourceSlug: $0.slug,
                    name: $0.name,
                    country: $0.provider.uppercased(),
                    logoURL: nil,
                    season: nil
                )
            }
    }

    func upcomingFixtures(for favorite: FavoriteItem, limit: Int) async throws -> [FixtureSummary] {
        guard let sourceSlug = favorite.sourceSlug else {
            throw APIError.missingSourceSlug
        }

        let payload: BackendFixtureListDTO = try await request(
            path: "/api/v1/fixtures/\(sourceSlug)",
            queryItems: [URLQueryItem(name: "limit", value: String(limit))]
        )

        let summaries = payload.fixtures.map { item in
            mapFixtureSummary(item, sourceSlug: payload.source.slug, resultMode: payload.mode)
        }

        for summary in summaries {
            fixtureCache[summary.id] = summary
        }

        return summaries
    }

    func fixtureDetails(id: Int) async throws -> FixtureDetail {
        guard let summary = fixtureCache[id] else {
            throw APIError.missingFixture
        }

        return FixtureDetail(
            summary: summary,
            statistics: [],
            lineups: [],
            notes: detailNotes(for: summary)
        )
    }

    private func request<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        guard let url = configuration.requestURL(path: path, queryItems: queryItems) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8))
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    private func mapFixtureSummary(
        _ item: BackendFixtureDTO,
        sourceSlug: String,
        resultMode: String
    ) -> FixtureSummary {
        let identity = "\(sourceSlug)|\(item.kickoff.timeIntervalSince1970)|\(item.homeTeam)|\(item.awayTeam)|\(item.sourceURL)"

        return FixtureSummary(
            id: stableIdentifier(for: identity),
            sourceSlug: sourceSlug,
            sourceURL: URL(string: item.sourceURL),
            resultMode: resultMode,
            competitionName: item.competition,
            kickoff: item.kickoff,
            status: item.status,
            homeTeam: item.homeTeam,
            awayTeam: item.awayTeam,
            venue: item.venue,
            broadcastChannels: []
        )
    }

    private func detailNotes(for summary: FixtureSummary) -> [String] {
        var notes = [
            summary.resultMode == "recent"
                ? "These fixtures are recent matches from the backend because no upcoming matches were available in the current scrape window."
                : "This fixture came from the local FootballPulse backend.",
            "Detailed stats and lineups will be added to the backend next, then surfaced here."
        ]

        if let sourceURL = summary.sourceURL?.absoluteString {
            notes.append("FBref source: \(sourceURL)")
        } else {
            notes.append("FBref source URL unavailable.")
        }

        return notes
    }
}

private struct BackendSourceDTO: Decodable {
    let slug: String
    let name: String
    let sourceType: String
    let provider: String

    enum CodingKeys: String, CodingKey {
        case slug
        case name
        case sourceType = "source_type"
        case provider
    }
}

private struct BackendFixtureListDTO: Decodable {
    let source: BackendSourceDTO
    let mode: String
    let fixtures: [BackendFixtureDTO]
}

private struct BackendFixtureDTO: Decodable {
    let competition: String
    let kickoff: Date
    let homeTeam: String
    let awayTeam: String
    let status: String
    let score: String?
    let venue: String?
    let sourceURL: String

    enum CodingKeys: String, CodingKey {
        case competition
        case kickoff
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case status
        case score
        case venue
        case sourceURL = "source_url"
    }
}
