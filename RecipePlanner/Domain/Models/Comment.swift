import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let recipeId: Int
    let userId: String
    let username: String
    let text: String
    let timestamp: Double
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
