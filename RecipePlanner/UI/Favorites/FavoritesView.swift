import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(repository: container.recipeRepository))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "Loading favorites...")
                } else if viewModel.favorites.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        message: "No Favorites Yet",
                        description: "Tap the heart icon on recipes to save them here"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.favorites) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                    RecipeRow(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.removeFavorite(recipe)
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "heart.slash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await viewModel.loadFavorites()
                    }
                }
            }
            .navigationTitle("Favorites")
            .task {
                await viewModel.loadFavorites()
            }
        }
    }
}

