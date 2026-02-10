import Foundation

struct Ingredient: Identifiable, Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let image: String?
}
