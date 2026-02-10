import Foundation

struct MealPlan: Identifiable, Codable {
    let id: String
    let userId: String
    let recipeId: Int
    let recipeName: String
    let date: Date
    let mealType: MealType // breakfast, lunch, dinner
}

enum MealType: String, Codable {
    case breakfast, lunch, dinner, snack
}
