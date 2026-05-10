import SwiftUI
import SwiftData

struct PlansListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.createdAt) private var plans: [WorkoutPlan]
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    NavigationLink(value: plan) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name)
                                .font(.headline)
                            Text("\(plan.days.count) day\(plan.days.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deletePlans)
            }
            .navigationTitle("My Plans")
            .navigationDestination(for: WorkoutPlan.self) { plan in
                PlanDetailView(plan: plan)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingEditor = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if plans.isEmpty {
                    ContentUnavailableView(
                        "No Plans Yet",
                        systemImage: "dumbbell",
                        description: Text("Tap + to create your first workout plan.")
                    )
                }
            }
            .sheet(isPresented: $showingEditor) {
                PlanEditorView()
            }
        }
    }

    private func deletePlans(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(plans[index])
        }
    }
}
