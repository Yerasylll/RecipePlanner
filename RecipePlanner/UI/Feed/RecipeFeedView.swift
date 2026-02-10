import SwiftUI

struct RecipeFeedView: View {
    @StateObject private var viewModel: RecipeFeedViewModel
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: RecipeFeedViewModel(repository: container.recipeRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchQuery, placeholder: "Search recipes...")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Content
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    LoadingView(message: "Loading recipes...")
                } else if let error = viewModel.errorMessage, viewModel.recipes.isEmpty {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else if viewModel.recipes.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        message: "No recipes found",
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
                                .onAppear {
                                    if recipe.id == viewModel.recipes.last?.id {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Recipes")
            .task {
                if viewModel.recipes.isEmpty {
                    await viewModel.loadInitialRecipes()
                }
            }
        }
    }
}

