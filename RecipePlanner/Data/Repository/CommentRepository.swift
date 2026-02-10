import Foundation
import Combine

class CommentRepository {
    private let firebaseService: FirebaseRealtimeService
    
    init(firebaseService: FirebaseRealtimeService) {
        self.firebaseService = firebaseService
    }
    
    func addComment(recipeId: Int, userId: String, username: String, text: String) async throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CommentError.emptyComment
        }
        
        try await firebaseService.addComment(
            recipeId: recipeId,
            userId: userId,
            username: username,
            text: text
        )
    }
    
    func observeComments(recipeId: Int, completion: @escaping ([Comment]) -> Void) {
        firebaseService.observeComments(recipeId: recipeId, completion: completion)
    }
    
    func removeObserver(recipeId: Int) {
        firebaseService.removeCommentObserver(recipeId: recipeId)
    }
    
    func deleteComment(recipeId: Int, commentId: String, userId: String) async throws {
        // Only allow users to delete their own comments
        try await firebaseService.deleteComment(recipeId: recipeId, commentId: commentId)
    }
}

enum CommentError: LocalizedError {
    case emptyComment
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .emptyComment:
            return "Comment cannot be empty"
        case .unauthorized:
            return "You can only delete your own comments"
        }
    }
}
