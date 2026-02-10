import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noInternet
    case timeout
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .httpError(let code):
            return "Server error: \(code)"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

