import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed
    case missingFixture
    case missingSourceSlug

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The backend request URL could not be created."
        case .invalidResponse:
            return "The backend returned an invalid response."
        case let .requestFailed(statusCode, message):
            if statusCode == 502, let friendly = Self.userFacingMessageFor502(from: message) {
                return friendly
            }
            if let message, message.isEmpty == false {
                return "Backend request failed with status \(statusCode): \(message)"
            }
            return "Backend request failed with status \(statusCode)."
        case .decodingFailed:
            return "The backend response could not be decoded."
        case .missingFixture:
            return "Fixture details were not found."
        case .missingSourceSlug:
            return "This item is missing a backend source identifier."
        }
    }

    /// FastAPI returns `{"detail":"..."}`; strip noise so the dashboard does not show raw JSON.
    private static func userFacingMessageFor502(from raw: String?) -> String? {
        guard let raw, raw.isEmpty == false, let data = raw.data(using: .utf8) else { return nil }
        let detail: String?
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let s = obj["detail"] as? String {
                detail = s
            } else if let arr = obj["detail"] as? [[String: Any]] {
                detail = arr.compactMap { $0["msg"] as? String }.joined(separator: " ")
            } else {
                detail = nil
            }
        } else {
            detail = nil
        }

        guard let detail, detail.isEmpty == false else {
            return "Live fixtures are unavailable right now (bad gateway). You can turn on mock data in Settings to keep working on the UI."
        }

        let condensed = detail.replacingOccurrences(
            of: #"\s*URL:\s*https?://\S+"#,
            with: "",
            options: .regularExpression
        )

        if condensed.localizedCaseInsensitiveContains("cloudflare")
            || condensed.localizedCaseInsensitiveContains("fbref") {
            return "Live fixtures are unavailable: the stats site blocked the server (often Cloudflare). Use mock data in Settings for now, or try again later."
        }

        return condensed
    }
}

struct BackendConfiguration: Sendable {
    let baseURL: URL

    /// Simulator / local dev default when Info.plist did not get a resolved URL (Debug only).
    private static let debugFallbackLocalBackend = URL(string: "http://127.0.0.1:8000")!

    static func fromBundle(_ bundle: Bundle = .main) -> BackendConfiguration? {
        let rawBaseURL = bundle.object(forInfoDictionaryKey: "BackendBaseURL") as? String
        let trimmed = rawBaseURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if trimmed.isEmpty || trimmed.contains("$(BACKEND_BASE_URL)") || trimmed.contains("$(") {
            #if DEBUG
            return BackendConfiguration(baseURL: debugFallbackLocalBackend)
            #else
            return nil
            #endif
        }

        guard let baseURL = URL(string: trimmed) else {
            #if DEBUG
            return BackendConfiguration(baseURL: debugFallbackLocalBackend)
            #else
            return nil
            #endif
        }

        guard let host = baseURL.host, host.isEmpty == false else {
            #if DEBUG
            return BackendConfiguration(baseURL: debugFallbackLocalBackend)
            #else
            return nil
            #endif
        }

        // Common mistake: BACKEND_BASE_URL = http://api — requests become http://api/v1/... and fail DNS.
        if host.caseInsensitiveCompare("api") == .orderedSame {
            #if DEBUG
            return BackendConfiguration(baseURL: debugFallbackLocalBackend)
            #else
            return nil
            #endif
        }

        return BackendConfiguration(baseURL: baseURL)
    }

    /// Builds an absolute URL without mutating `URLComponents` from a full base URL (avoids host/port bugs on some OS versions).
    func requestURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        let segments = path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)

        let pathString: String
        if segments.isEmpty {
            pathString = "/"
        } else {
            pathString = "/" + segments.joined(separator: "/")
        }

        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = pathString
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}
