import Foundation
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let authService = FirebaseAuthService.shared
    
    init() {
        if let profile = authService.userProfile {
            username = profile.username
            email = profile.email
        }
    }
    
    func saveChanges() async {
        errorMessage = nil
        successMessage = nil
        
        // Validate
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }
        
        if !newPassword.isEmpty {
            guard !currentPassword.isEmpty else {
                errorMessage = "Enter current password to change password"
                return
            }
            
            guard newPassword.count >= 6 else {
                errorMessage = "New password must be at least 6 characters"
                return
            }
            
            guard newPassword == confirmPassword else {
                errorMessage = "Passwords do not match"
                return
            }
        }
        
        isLoading = true
        
        do {
            // Update username in Firebase
            try await authService.updateUsername(username)
            
            // Update password if provided
            if !newPassword.isEmpty {
                try await authService.updatePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )
            }
            
            successMessage = "Profile updated successfully!"
            
            // Clear password fields
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
