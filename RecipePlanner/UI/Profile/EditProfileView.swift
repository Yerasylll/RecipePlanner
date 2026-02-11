import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EditProfileViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Username", text: $viewModel.username)
                    TextField("Email", text: $viewModel.email)
                        .disabled(true)
                        .foregroundColor(.secondary)
                }
                
                Section("Change Password") {
                    SecureField("Current Password", text: $viewModel.currentPassword)
                    SecureField("New Password", text: $viewModel.newPassword)
                    SecureField("Confirm New Password", text: $viewModel.confirmPassword)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let success = viewModel.successMessage {
                    Section {
                        Text(success)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    Task {
                        await viewModel.saveChanges()
                    }
                }
                .disabled(viewModel.isLoading)
            )
        }
    }
}
