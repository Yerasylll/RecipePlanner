import Foundation

actor APIClient {
    private let baseURL = "https://api.spoonacular.com"
    private let apiKey: String
    private let session: URLSession
    
    init() {
        // Read API key from Info.plist
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "SPOONACULAR_API_KEY") as? String ?? ""
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = try endpoint.url(baseURL: baseURL, apiKey: apiKey)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                throw NetworkError.noInternet
            } else if urlError.code == .timedOut {
                throw NetworkError.timeout
            }
            throw NetworkError.unknown(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

