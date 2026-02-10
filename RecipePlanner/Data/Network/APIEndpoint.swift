import Foundation

enum APIEndpoint {
    case searchRecipes(query: String, offset: Int, number: Int)
    case recipeDetails(id: Int)
    case randomRecipes(number: Int)
    
    func url(baseURL: String, apiKey: String) throws -> URL {
        var components = URLComponents(string: baseURL)!
        
        switch self {
        case .searchRecipes(let query, let offset, let number):
            components.path = "/recipes/complexSearch"
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "number", value: "\(number)"),
                URLQueryItem(name: "apiKey", value: apiKey),
                URLQueryItem(name: "addRecipeInformation", value: "true"),
                URLQueryItem(name: "fillIngredients", value: "true")
            ]
            
        case .recipeDetails(let id):
            components.path = "/recipes/\(id)/information"
            components.queryItems = [
                URLQueryItem(name: "apiKey", value: apiKey),
                URLQueryItem(name: "includeNutrition", value: "false")
            ]
            
        case .randomRecipes(let number):
            components.path = "/recipes/random"
            components.queryItems = [
                URLQueryItem(name: "number", value: "\(number)"),
                URLQueryItem(name: "apiKey", value: apiKey)
            ]
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
}

