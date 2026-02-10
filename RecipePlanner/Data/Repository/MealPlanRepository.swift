import Foundation

class MealPlanRepository {
    private let firebaseService: FirebaseRealtimeService
    
    init(firebaseService: FirebaseRealtimeService) {
        self.firebaseService = firebaseService
    }
    
    func addMealPlan(userId: String, recipeId: Int, recipeName: String, date: Date, mealType: MealType) async throws {
        let mealPlan = MealPlan(
            id: UUID().uuidString,
            userId: userId,
            recipeId: recipeId,
            recipeName: recipeName,
            date: date,
            mealType: mealType
        )
        
        try await firebaseService.addMealPlan(mealPlan)
    }
    
    func getMealPlans(userId: String) async throws -> [MealPlan] {
        try await firebaseService.getMealPlans(userId: userId)
    }
    
    func deleteMealPlan(userId: String, mealPlanId: String) async throws {
        try await firebaseService.deleteMealPlan(userId: userId, mealPlanId: mealPlanId)
    }
}
