import Foundation

struct RecentRecipe: Identifiable {
    let recipeId: Int
    let recipeName: String
    let imageURL: String?
    let viewedAt: Date
    
    var id: Int { recipeId }
}
