import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await viewModel.signUp()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}
