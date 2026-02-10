import Foundation
import Combine

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: RecipeDetailResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFavorite = false
    
    private let repository: RecipeRepository
    private let recipeId: Int
    private let authService: FirebaseAuthService
    
    init(recipeId: Int, repository: RecipeRepository, authService: FirebaseAuthService = .shared) {
        self.recipeId = recipeId
        self.repository = repository
        self.authService = authService
    }
    
    func loadRecipe() async {
        isLoading = true
        errorMessage = nil
        
        do {
            recipe = try await repository.getRecipeDetails(id: recipeId)
            checkFavoriteStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFavorite() async {
        guard let recipe = recipe,
              let userId = authService.currentUserId else { return }
        
        let recipeModel = recipe.toRecipe()
        
        do {
            try await repository.toggleFavorite(recipe: recipeModel, userId: userId)
            isFavorite.toggle()
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }
    
    private func checkFavoriteStatus() {
        let favorites = repository.getFavorites()
        isFavorite = favorites.contains { $0.id == recipeId }
    }
}

