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
}

struct BackendConfiguration: Sendable {
    let baseURL: URL

    static func fromBundle(_ bundle: Bundle = .main) -> BackendConfiguration? {
        guard
            let rawBaseURL = bundle.object(forInfoDictionaryKey: "BackendBaseURL") as? String
        else {
            return nil
        }

        let baseURLString = rawBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard baseURLString.isEmpty == false, let baseURL = URL(string: baseURLString) else {
            return nil
        }

        return BackendConfiguration(baseURL: baseURL)
    }
}
