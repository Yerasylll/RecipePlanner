import Foundation

class AppContainer {
    static let shared = AppContainer()
    
    // Services
    lazy var apiClient: APIClient = {
        APIClient()
    }()
    
    lazy var coreDataStack: CoreDataStack = {
        CoreDataStack.shared
    }()
    
    lazy var firebaseAuthService: FirebaseAuthService = {
        FirebaseAuthService.shared
    }()
    
    lazy var firebaseRealtimeService: FirebaseRealtimeService = {
        FirebaseRealtimeService()
    }()
    
    // Data Sources
    lazy var localDataSource: LocalDataSource = {
        LocalDataSource(coreDataStack: coreDataStack)
    }()
    
    // Repositories
    lazy var recipeRepository: RecipeRepository = {
        RecipeRepository(
            apiClient: apiClient,
            localDataSource: localDataSource,
            firebaseService: firebaseRealtimeService
        )
    }()
    
    lazy var commentRepository: CommentRepository = {
        CommentRepository(firebaseService: firebaseRealtimeService)
    }()
    
    lazy var mealPlanRepository: MealPlanRepository = {
        MealPlanRepository(firebaseService: firebaseRealtimeService)
    }()
    
    private init() {}
}

