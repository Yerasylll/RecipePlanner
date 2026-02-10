import Foundation
import Combine

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var newCommentText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CommentRepository
    private let authService: FirebaseAuthService
    private let recipeId: Int
    
    init(recipeId: Int, repository: CommentRepository, authService: FirebaseAuthService = .shared) {
        self.recipeId = recipeId
        self.repository = repository
        self.authService = authService
    }
    
    func startObserving() {
        repository.observeComments(recipeId: recipeId) { [weak self] comments in
            DispatchQueue.main.async {
                self?.comments = comments
            }
        }
    }
    
    func stopObserving() {
        repository.removeObserver(recipeId: recipeId)
    }
    
    func addComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let userId = authService.currentUserId,
              let username = authService.currentUsername else {
            errorMessage = "Unable to post comment"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.addComment(
                recipeId: recipeId,
                userId: userId,
                username: username,
                text: newCommentText
            )
            newCommentText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteComment(_ comment: Comment) async {
        guard comment.userId == authService.currentUserId else {
            errorMessage = "You can only delete your own comments"
            return
        }
        
        do {
            try await repository.deleteComment(
                recipeId: recipeId,
                commentId: comment.id,
                userId: comment.userId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

