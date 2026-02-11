import SwiftUI
import Kingfisher

struct RecipeDetailView: View {
    let recipeId: Int
    @StateObject private var viewModel: RecipeDetailViewModel
    @State private var showingComments = false
    @State private var showingRatingSheet = false
    @State private var showingMealPlanSheet = false
    @State private var averageRating: Double = 0.0
    @State private var ratingCount: Int = 0
    
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
                        
                        // Rating Display
                        if averageRating > 0 {
                            HStack(spacing: 8) {
                                StarRatingView(rating: averageRating, starSize: 18)
                                Text(String(format: "%.1f", averageRating))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("(\(ratingCount) reviews)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Info chips
                        HStack(spacing: 12) {
                            if let time = recipe.readyInMinutes {
                                RecipeInfoChip(icon: "clock", text: "\(time) min")
                            }
                            
                            if let servings = recipe.servings {
                                RecipeInfoChip(icon: "person.2", text: "\(servings) servings")
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
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Rate Recipe Button
                            Button {
                                showingRatingSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Rate this Recipe")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            // Add to Meal Plan Button
                            Button {
                                showingMealPlanSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Add to Meal Plan")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
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
            await loadRatings()
            saveToRecentlyViewed()
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(recipeId: recipeId)
        }
        .sheet(isPresented: $showingRatingSheet) {
            RatingSheetView(recipeId: recipeId) {
                Task {
                    await loadRatings()
                }
            }
            .environmentObject(FirebaseAuthService.shared)
        }
        .sheet(isPresented: $showingMealPlanSheet) {
            if let recipe = viewModel.recipe {
                MealPlanCalendarView(recipeId: recipe.id, recipeName: recipe.title)
            }
        }
    }
    
    private func cleanHTML(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    private func loadRatings() async {
        do {
            let firebaseService = AppContainer.shared.firebaseRealtimeService
            let ratings = try await firebaseService.getRatings(recipeId: recipeId)
            
            await MainActor.run {
                ratingCount = ratings.count
                if !ratings.isEmpty {
                    let sum = ratings.reduce(0) { $0 + $1.rating }
                    averageRating = Double(sum) / Double(ratings.count)
                }
            }
        } catch {
            print("Error loading ratings: \(error)")
        }
    }
    
    private func saveToRecentlyViewed() {
        guard let userId = FirebaseAuthService.shared.currentUserId,
              let recipe = viewModel.recipe else { return }
        
        Task {
            do {
                let firebaseService = AppContainer.shared.firebaseRealtimeService
                try await firebaseService.saveRecentlyViewed(
                    userId: userId,
                    recipeId: recipe.id,
                    recipeName: recipe.title,
                    imageURL: recipe.image
                )
            } catch {
                print("Error saving recently viewed: \(error)")
            }
        }
    }
}

// Separate component to avoid naming conflict
struct RecipeInfoChip: View {
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

