import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: SearchViewModel(repository: container.recipeRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchQuery, placeholder: "Search for recipes...")
                    .padding()
                
                if viewModel.searchQuery.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        message: "Start Searching",
                        description: "Type to find delicious recipes"
                    )
                } else if viewModel.isLoading {
                    LoadingView(message: "Searching...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        // Retry handled automatically by debounce
                    }
                } else if viewModel.recipes.isEmpty {
                    EmptyStateView(
                        icon: "exclamationmark.magnifyingglass",
                        message: "No Results",
                        description: "Try a different search term"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.recipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                    RecipeRow(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

