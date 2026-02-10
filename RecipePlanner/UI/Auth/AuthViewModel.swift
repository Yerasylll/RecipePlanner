import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService: FirebaseAuthService
    
    init(authService: FirebaseAuthService = .shared) {
        self.authService = authService
    }
    
    func signIn() async {
        guard validateInput(requireUsername: false) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard validateInput(requireUsername: true) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signUp(email: email, password: password, username: username)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func validateInput(requireUsername: Bool) -> Bool {
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        if requireUsername && username.isEmpty {
            errorMessage = "Username is required"
            return false
        }
        
        return true
    }
}

