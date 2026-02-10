import SwiftUI
import Kingfisher

struct RecipeDetailView: View {
    let recipeId: Int
    @StateObject private var viewModel: RecipeDetailViewModel
    @State private var showingComments = false
    
    init(recipeId: Int) {
        self.recipeId = recipeId
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(
            recipeId: recipeId,
            repository: container.recipeRepository
        ))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                LoadingView(message: "Loading recipe...")
                    .frame(height: 400)
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    Task {
                        await viewModel.loadRecipe()
                    }
                }
            } else if let recipe = viewModel.recipe {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let imageURL = recipe.image {
                        KFImage(URL(string: imageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Info chips
                        HStack(spacing: 12) {
                            if let time = recipe.readyInMinutes {
                                InfoChip(icon: "clock", text: "\(time) min")
                            }
                            
                            if let servings = recipe.servings {
                                InfoChip(icon: "person.2", text: "\(servings) servings")
                            }
                            
                            Spacer()
                            
                            // Favorite button
                            Button {
                                Task {
                                    await viewModel.toggleFavorite()
                                }
                            } label: {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isFavorite ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        // Summary
                        if let summary = recipe.summary {
                            Text(cleanHTML(summary))
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        
                        // Ingredients
                        if let ingredients = recipe.extendedIngredients, !ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ingredients")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ForEach(ingredients, id: \.id) { ingredient in
                                    HStack {
                                        Text("•")
                                        Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }
                        
                        // Instructions
                        if let instructions = recipe.instructions {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Instructions")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                Text(cleanHTML(instructions))
                                    .font(.body)
                            }
                        }
                        
                        // Comments button
                        Button {
                            showingComments = true
                        } label: {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                Text("View Comments")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadRecipe()
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(recipeId: recipeId)
        }
    }
    
    private func cleanHTML(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .cornerRadius(8)
    }
}

