import SwiftUI
import Kingfisher

struct RecipeFeedView: View {
    @StateObject private var viewModel: RecipeFeedViewModel
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: RecipeFeedViewModel(repository: container.recipeRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar at Top
                SearchBar(text: $viewModel.searchQuery, placeholder: "Search recipes...")
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
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
                        VStack(spacing: 16) {
                            // Recently Viewed Section
                            if !viewModel.recentRecipes.isEmpty && viewModel.searchQuery.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recently Viewed")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.recentRecipes) { recent in
                                                NavigationLink(destination: RecipeDetailView(recipeId: recent.recipeId)) {
                                                    RecentRecipeCard(recipe: recent)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            
                            // All Recipes
                            LazyVStack(spacing: 12) {
                                if viewModel.searchQuery.isEmpty {
                                    Text("All Recipes")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                }
                                
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
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if viewModel.recipes.isEmpty {
                await viewModel.loadInitialRecipes()
            }
            await viewModel.loadRecentRecipes()
        }
    }
}

// Recent Recipe Card Component
struct RecentRecipeCard: View {
    let recipe: RecentRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = recipe.imageURL {
                KFImage(URL(string: imageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 100)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            Text(recipe.recipeName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
    }
}

