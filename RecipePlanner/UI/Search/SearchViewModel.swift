import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: RecipeRepository
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: RecipeRepository) {
        self.repository = repository
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.recipes = []
                    return
                }
                Task {
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        searchTask?.cancel()
        
        searchTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                recipes = try await repository.searchRecipes(query: query, offset: 0)
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
            
            isLoading = false
        }
    }
}
