import Foundation

// MARK: - Search Response
struct RecipeSearchResponse: Codable {
    let results: [Recipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}

// MARK: - Random Recipes Response
struct RandomRecipesResponse: Codable {
    let recipes: [Recipe]
}

// MARK: - Detailed Recipe Response
struct RecipeDetailResponse: Codable {
    let id: Int
    let title: String
    let image: String?
    let summary: String?
    let readyInMinutes: Int?
    let servings: Int?
    let sourceUrl: String?
    let extendedIngredients: [IngredientDetail]?
    let instructions: String?
    let cuisines: [String]?
    let dishTypes: [String]?
    
    func toRecipe() -> Recipe {
        Recipe(
            id: id,
            title: title,
            image: image,
            summary: summary,
            readyInMinutes: readyInMinutes,
            servings: servings,
            sourceUrl: sourceUrl,
            isFavorite: false
        )
    }
}

// MARK: - Ingredient Detail
struct IngredientDetail: Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let image: String?
    
    func toIngredient() -> Ingredient {
        Ingredient(id: id, name: name, amount: amount, unit: unit, image: image)
    }
}

