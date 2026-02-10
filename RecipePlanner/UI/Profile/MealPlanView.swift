import SwiftUI

struct MealPlanView: View {
    @StateObject private var viewModel: MealPlanViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        let container = AppContainer.shared
        _viewModel = StateObject(wrappedValue: MealPlanViewModel(repository: container.mealPlanRepository))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "Loading meal plans...")
                } else if viewModel.mealPlans.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        message: "No Meal Plans",
                        description: "Start planning your meals from recipe details"
                    )
                } else {
                    List {
                        ForEach(groupedMealPlans.keys.sorted(), id: \.self) { date in
                            Section(header: Text(date, style: .date)) {
                                ForEach(groupedMealPlans[date] ?? []) { mealPlan in
                                    MealPlanRow(mealPlan: mealPlan)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                Task {
                                                    await viewModel.deleteMealPlan(mealPlan)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meal Plans")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .task {
                await viewModel.loadMealPlans()
            }
        }
    }
    
    private var groupedMealPlans: [Date: [MealPlan]] {
        Dictionary(grouping: viewModel.mealPlans) { mealPlan in
            Calendar.current.startOfDay(for: mealPlan.date)
        }
    }
}

struct MealPlanRow: View {
    let mealPlan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mealPlan.recipeName)
                .font(.headline)
            
            HStack {
                Image(systemName: mealTypeIcon)
                    .foregroundColor(.orange)
                Text(mealPlan.mealType.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var mealTypeIcon: String {
        switch mealPlan.mealType {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "leaf"
        }
    }
}

