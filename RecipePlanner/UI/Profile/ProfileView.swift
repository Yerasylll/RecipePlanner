import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingMealPlans = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let profile = viewModel.userProfile {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(profile.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Button {
                            showingEditProfile = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                    }
                }
                
                Section("Features") {
                    Button {
                        showingMealPlans = true
                    } label: {
                        Label("Meal Plans", systemImage: "calendar")
                            .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingMealPlans) {
                MealPlanView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
}
