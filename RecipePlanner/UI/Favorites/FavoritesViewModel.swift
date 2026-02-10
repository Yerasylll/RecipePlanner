import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: RecipeRepository
    private let authService: FirebaseAuthService
    
    init(repository: RecipeRepository, authService: FirebaseAuthService = .shared) {
        self.repository = repository
        self.authService = authService
    }
    
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        // Sync from Firebase first
        if let userId = authService.currentUserId {
            do {
                try await repository.syncFavorites(userId: userId)
            } catch {
                errorMessage = "Sync failed: \(error.localizedDescription)"
            }
        }
        
        // Load from local cache
        favorites = repository.getFavorites()
        isLoading = false
    }
    
    func removeFavorite(_ recipe: Recipe) async {
        guard let userId = authService.currentUserId else { return }
        
        do {
            try await repository.toggleFavorite(recipe: recipe, userId: userId)
            favorites.removeAll { $0.id == recipe.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

