import SwiftUI

struct CommentsView: View {
    let recipeId: Int
    @StateObject private var viewModel: CommentsViewModel
    @Environment(\.dismiss) var dismiss
    
    init(recipeId: Int) {
        self.recipeId = recipeId
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: CommentsViewModel(
            recipeId: recipeId,
            repository: container.commentRepository
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments list
                if viewModel.comments.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left",
                        message: "No comments yet",
                        description: "Be the first to comment!"
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.comments) { comment in
                                CommentRow(
                                    comment: comment,
                                    onDelete: {
                                        Task {
                                            await viewModel.deleteComment(comment)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                Divider()
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $viewModel.newCommentText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button {
                        Task {
                            await viewModel.addComment()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(viewModel.newCommentText.isEmpty ? Color.gray : Color.orange)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.newCommentText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .onAppear {
                viewModel.startObserving()
            }
            .onDisappear {
                viewModel.stopObserving()
            }
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    let onDelete: () -> Void
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(comment.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if comment.userId == authService.currentUserId {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            
            Text(comment.text)
                .font(.body)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
