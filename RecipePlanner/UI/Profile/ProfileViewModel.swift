import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    
    private let authService: FirebaseAuthService
    
    init(authService: FirebaseAuthService = .shared) {
        self.authService = authService
        self.userProfile = authService.userProfile
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

