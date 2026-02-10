import Foundation
import Combine

@MainActor
class MealPlanViewModel: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: MealPlanRepository
    private let authService: FirebaseAuthService
    
    init(repository: MealPlanRepository, authService: FirebaseAuthService = .shared) {
        self.repository = repository
        self.authService = authService
    }
    
    func loadMealPlans() async {
        guard let userId = authService.currentUserId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            mealPlans = try await repository.getMealPlans(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteMealPlan(_ mealPlan: MealPlan) async {
        guard let userId = authService.currentUserId else { return }
        
        do {
            try await repository.deleteMealPlan(userId: userId, mealPlanId: mealPlan.id)
            mealPlans.removeAll { $0.id == mealPlan.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addMealPlan(recipeId: Int, recipeName: String, date: Date, mealType: MealType) async {
        guard let userId = authService.currentUserId else { return }
        
        do {
            try await repository.addMealPlan(
                userId: userId,
                recipeId: recipeId,
                recipeName: recipeName,
                date: date,
                mealType: mealType
            )
            await loadMealPlans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

