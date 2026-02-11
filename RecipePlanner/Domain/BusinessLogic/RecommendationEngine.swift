import Foundation

class RecommendationEngine {
    
    /// Calculate recommendation score for a recipe
    /// Higher score = better recommendation
    static func calculateScore(
        recipe: Recipe,
        favoritesCount: Int,
        ingredientMatch: Int,
        recentViews: Int
    ) -> Int {
        var score = 0
        
        // Weight factors
        score += favoritesCount * 2  // Favorites matter more
        score += ingredientMatch * 3  // Ingredient match is most important
        score += recentViews * 1      // Recent views matter least
        
        // Bonus for quick recipes
        if let time = recipe.readyInMinutes, time <= 30 {
            score += 5
        }
        
        return score
    }
    
    /// Get recommended recipes based on user preferences
    static func getRecommendations(
        from recipes: [Recipe],
        userFavorites: [Recipe],
        maxResults: Int = 10
    ) -> [Recipe] {
        
        let scored = recipes.map { recipe -> (recipe: Recipe, score: Int) in
            let favCount = userFavorites.filter { $0.id == recipe.id }.count
            let score = calculateScore(
                recipe: recipe,
                favoritesCount: favCount,
                ingredientMatch: 0, // Can be enhanced with actual ingredient matching
                recentViews: 0
            )
            return (recipe, score)
        }
        
        return scored
            .sorted { $0.score > $1.score }
            .prefix(maxResults)
            .map { $0.recipe }
    }
}
