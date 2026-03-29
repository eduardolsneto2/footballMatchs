import Foundation

struct HTTPClient: Sendable {
    func get<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        configuration: BackendConfiguration
    ) async throws -> Response {
        guard var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        components.path = "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(
                statusCode: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
