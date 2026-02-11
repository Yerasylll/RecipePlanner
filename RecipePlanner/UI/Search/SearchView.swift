import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: SearchViewModel(repository: container.recipeRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Prominent Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for recipes...", text: $viewModel.searchQuery)
                        .focused($isSearchFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Results
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
            .onAppear {
                isSearchFocused = true
            }
        }
    }
}

