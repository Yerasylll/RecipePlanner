import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    let username: String
    let email: String
    let createdAt: Date
}
