import SwiftUI

struct MealPlanCalendarView: View {
    let recipeId: Int
    let recipeName: String
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedMealType: MealType = .dinner
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Plan your meal")
                    .font(.headline)
                    .padding(.top)
                
                // Date Picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                
                // Meal Type Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Meal Type")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach([MealType.breakfast, .lunch, .dinner, .snack], id: \.self) { type in
                            Button {
                                selectedMealType = type
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: mealTypeIcon(type))
                                        .font(.title2)
                                    Text(type.rawValue.capitalized)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedMealType == type ? Color.orange : Color(.systemGray6))
                                .foregroundColor(selectedMealType == type ? .white : .primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                // Submit Button
                Button {
                    Task {
                        await addMealPlan()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Add to Meal Plan")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isSubmitting)
            }
            .navigationTitle("Plan Meal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func mealTypeIcon(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "leaf"
        }
    }
    
    private func addMealPlan() async {
        guard let userId = FirebaseAuthService.shared.currentUserId else {
            errorMessage = "Please sign in"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let repository = AppContainer.shared.mealPlanRepository
            try await repository.addMealPlan(
                userId: userId,
                recipeId: recipeId,
                recipeName: recipeName,
                date: selectedDate,
                mealType: selectedMealType
            )
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
}
