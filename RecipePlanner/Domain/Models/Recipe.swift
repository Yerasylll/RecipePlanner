import Foundation

struct Recipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String?
    let summary: String?
    let readyInMinutes: Int?
    let servings: Int?
    let sourceUrl: String?
    var isFavorite: Bool = false
    
    // API response keys
    enum CodingKeys: String, CodingKey {
        case id, title, image, summary
        case readyInMinutes, servings, sourceUrl
    }
}
