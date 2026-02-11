import Foundation

struct Rating: Identifiable, Codable {
    let id: String
    let recipeId: Int
    let userId: String
    let username: String
    let rating: Int // 1-5
    let review: String?
    let timestamp: Double
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
