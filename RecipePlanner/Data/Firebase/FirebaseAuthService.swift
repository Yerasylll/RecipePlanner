import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

class FirebaseAuthService: ObservableObject {
    static let shared = FirebaseAuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var userProfile: UserProfile?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var currentUsername: String? {
        userProfile?.username
    }
    
    private init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let userId = user?.uid {
                    await self?.loadUserProfile(userId: userId)
                } else {
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        await MainActor.run {
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, username: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Create user profile in Realtime DB
        let profile = UserProfile(
            id: result.user.uid,
            username: username,
            email: email,
            createdAt: Date()
        )
        
        try await saveUserProfile(profile)
        
        await MainActor.run {
            self.currentUser = result.user
            self.isAuthenticated = true
            self.userProfile = profile
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
        userProfile = nil
    }
    
    // MARK: - User Profile
    private func saveUserProfile(_ profile: UserProfile) async throws {
        let ref = Database.database().reference().child("users").child(profile.id)
        
        let data: [String: Any] = [
            "username": profile.username,
            "email": profile.email,
            "createdAt": profile.createdAt.timeIntervalSince1970
        ]
        
        try await ref.setValue(data)
    }
    
    private func loadUserProfile(userId: String) async {
        let ref = Database.database().reference().child("users").child(userId)
        
        do {
            let snapshot = try await ref.getData()
            
            if let data = snapshot.value as? [String: Any],
               let username = data["username"] as? String,
               let email = data["email"] as? String,
               let timestamp = data["createdAt"] as? Double {
                
                let profile = UserProfile(
                    id: userId,
                    username: username,
                    email: email,
                    createdAt: Date(timeIntervalSince1970: timestamp)
                )
                
                await MainActor.run {
                    self.userProfile = profile
                }
            }
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
