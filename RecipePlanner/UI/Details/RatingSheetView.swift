import SwiftUI

struct RatingSheetView: View {
    let recipeId: Int
    let onRatingSubmitted: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var selectedRating: Int = 0
    @State private var reviewText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How would you rate this recipe?")
                    .font(.headline)
                    .padding(.top, 32)
                
                InteractiveStarRatingView(rating: $selectedRating, starSize: 40)
                
                if selectedRating > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Write a review (optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $reviewText)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Debug info (remove in production)
                VStack(spacing: 4) {
                    if let userId = authService.currentUserId {
                        Text("User ID: ")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("User ID: ")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    
                    if let username = authService.currentUsername {
                        Text("Username: \(username)")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("Username: ")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
                
                Spacer()
                
                Button {
                    Task {
                        await submitRating()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Submit Rating")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedRating > 0 ? Color.orange : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(selectedRating == 0 || isSubmitting)
            }
            .navigationTitle("Rate Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func submitRating() async {
        print("🔍 Submit rating started")
        print("   User ID: \(authService.currentUserId ?? "nil")")
        print("   Username: \(authService.currentUsername ?? "nil")")
        
        guard let userId = authService.currentUserId else {
            errorMessage = "User ID not found. Please sign out and sign in again."
            print("No user ID")
            return
        }
        
        guard let username = authService.currentUsername else {
            errorMessage = "Username not found. Please update your profile."
            print("No username")
            return
        }
        
        print("Auth check passed. Submitting rating...")
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let firebaseService = AppContainer.shared.firebaseRealtimeService
            try await firebaseService.addRating(
                recipeId: recipeId,
                userId: userId,
                username: username,
                rating: selectedRating,
                review: reviewText.isEmpty ? nil : reviewText
            )
            
            print("Rating submitted successfully")
            
            await MainActor.run {
                onRatingSubmitted()
                dismiss()
            }
        } catch {
            print("Rating submission error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}
