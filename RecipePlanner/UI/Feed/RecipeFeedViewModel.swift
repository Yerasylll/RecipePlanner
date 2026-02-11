import Foundation
import Combine

@MainActor
class RecipeFeedViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var recentRecipes: [RecentRecipe] = []
    
    private let repository: RecipeRepository
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var currentOffset = 0
    private var canLoadMore = true
    
    init(repository: RecipeRepository) {
        self.repository = repository
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.searchRecipes(query: query, reset: true)
                }
            }
            .store(in: &cancellables)
    }
    
    func loadInitialRecipes() async {
        await searchRecipes(query: "popular", reset: true)
    }
    
    func searchRecipes(query: String, reset: Bool = false) async {
        searchTask?.cancel()
        
        searchTask = Task {
            if reset {
                currentOffset = 0
                recipes = []
                canLoadMore = true
            }
            
            if reset {
                isLoading = true
            } else {
                isLoadingMore = true
            }
            
            errorMessage = nil
            
            do {
                let newRecipes = try await repository.searchRecipes(
                    query: query.isEmpty ? "popular" : query,
                    offset: currentOffset
                )
                
                if !Task.isCancelled {
                    recipes.append(contentsOf: newRecipes)
                    currentOffset += newRecipes.count
                    
                    if newRecipes.count < 20 {
                        canLoadMore = false
                    }
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
            
            isLoading = false
            isLoadingMore = false
        }
    }
    
    func loadMore() async {
        guard !isLoadingMore && canLoadMore else { return }
        await searchRecipes(query: searchQuery, reset: false)
    }
    
    func refresh() async {
        await searchRecipes(query: searchQuery, reset: true)
    }
    
    func loadRecentRecipes() async {
        guard let userId = FirebaseAuthService.shared.currentUserId else { return }
        
        do {
            let firebaseService = AppContainer.shared.firebaseRealtimeService
            recentRecipes = try await firebaseService.getRecentlyViewed(userId: userId, limit: 10)
        } catch {
            print("Error loading recent recipes: \(error)")
        }
    }
}

