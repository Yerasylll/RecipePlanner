import Foundation

class RecipeRepository {
    private let apiClient: APIClient
    private let localDataSource: LocalDataSource
    private let firebaseService: FirebaseRealtimeService
    
    init(apiClient: APIClient,
         localDataSource: LocalDataSource,
         firebaseService: FirebaseRealtimeService) {
        self.apiClient = apiClient
        self.localDataSource = localDataSource
        self.firebaseService = firebaseService
    }
    
    // MARK: - Search Recipes
    func searchRecipes(query: String, offset: Int) async throws -> [Recipe] {
        do {
            let response: RecipeSearchResponse = try await apiClient.request(
                .searchRecipes(query: query.isEmpty ? "popular" : query, offset: offset, number: 20)
            )
            
            // Cache results
            localDataSource.saveRecipes(response.results)
            
            return response.results
        } catch NetworkError.noInternet {
            // Fallback to cache
            return localDataSource.getCachedRecipes(query: query, offset: offset)
        } catch {
            throw error
        }
    }
    
    // MARK: - Get Recipe Details
    func getRecipeDetails(id: Int) async throws -> RecipeDetailResponse {
        do {
            let details: RecipeDetailResponse = try await apiClient.request(.recipeDetails(id: id))
            
            // Cache the basic recipe info
            localDataSource.saveRecipes([details.toRecipe()])
            
            return details
        } catch NetworkError.noInternet {
            // Try to get from cache
            let cached = localDataSource.getCachedRecipes(query: "", offset: 0)
            if let recipe = cached.first(where: { $0.id == id }) {
                // Return minimal details from cache
                return RecipeDetailResponse(
                    id: recipe.id,
                    title: recipe.title,
                    image: recipe.image,
                    summary: recipe.summary,
                    readyInMinutes: recipe.readyInMinutes,
                    servings: recipe.servings,
                    sourceUrl: recipe.sourceUrl,
                    extendedIngredients: nil,
                    instructions: nil,
                    cuisines: nil,
                    dishTypes: nil
                )
            }
            throw NetworkError.noInternet
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(recipe: Recipe, userId: String) async throws {
        let newFavoriteStatus = !recipe.isFavorite
        
        // Update Firebase
        if newFavoriteStatus {
            try await firebaseService.addFavorite(userId: userId, recipeId: recipe.id)
        } else {
            try await firebaseService.removeFavorite(userId: userId, recipeId: recipe.id)
        }
        
        // Update local cache
        localDataSource.updateFavoriteStatus(recipeId: recipe.id, isFavorite: newFavoriteStatus)
    }
    
    // MARK: - Get Favorites
    func getFavorites() -> [Recipe] {
        localDataSource.getFavorites()
    }
    
    // MARK: - Sync Favorites from Firebase
    func syncFavorites(userId: String) async throws {
        let favoriteIds = try await firebaseService.getFavorites(userId: userId)
        
        // Update local cache
        for id in favoriteIds {
            localDataSource.updateFavoriteStatus(recipeId: id, isFavorite: true)
        }
    }
}
