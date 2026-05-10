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
                    Menu {
                        Button {
                            showingEditor = true
                        } label: {
                            Label("New Plan", systemImage: "square.and.pencil")
                        }
                        Button {
                            importPPL()
                        } label: {
                            Label("Import Sample PPL Program", systemImage: "arrow.down.doc")
                        }
                    } label: {
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

    private func importPPL() {
        let plan = WorkoutPlan(name: "Push / Pull / Legs")

        let daysData: [(Weekday, String, [(String, Int, Int, String)])] = [
            (.monday, "Push – Heavy", [
                ("Bench Press", 3, 6, "Heavy: 5–8 rep range"),
                ("Overhead Press", 3, 8, ""),
                ("Dumbbell Incline Press", 3, 10, ""),
                ("Tricep Pushdowns", 3, 12, ""),
                ("Lateral Raises", 3, 15, ""),
            ]),
            (.tuesday, "Pull – Heavy", [
                ("Deadlifts", 3, 5, "Heavy"),
                ("Lat Pulldowns / Pull-ups", 3, 8, ""),
                ("Seated Cable Rows", 3, 10, ""),
                ("Face Pulls", 3, 15, "Rear delts / postural health"),
                ("Bicep Curls", 3, 12, "Hammer or barbell"),
            ]),
            (.wednesday, "Legs – Heavy", [
                ("Back Squats", 3, 6, "Heavy: 5–8 rep range"),
                ("Leg Press", 3, 10, ""),
                ("Leg Curls", 3, 12, ""),
                ("Calf Raises", 4, 15, ""),
            ]),
            (.thursday, "Pull – Volume", [
                ("Lat Pulldowns / Pull-ups", 3, 10, ""),
                ("Seated Cable Rows", 3, 10, ""),
                ("Face Pulls", 3, 15, "Rear delts / postural health"),
                ("Bicep Curls", 3, 12, "Hammer or barbell"),
            ]),
            (.friday, "Push – Volume", [
                ("Bench Press", 3, 10, "Volume: 10–12 rep range"),
                ("Overhead Press", 3, 10, ""),
                ("Dumbbell Incline Press", 3, 12, ""),
                ("Tricep Pushdowns", 3, 15, ""),
                ("Lateral Raises", 3, 20, ""),
            ]),
            (.saturday, "Legs – Volume", [
                ("Back Squats", 3, 10, "Volume: 10–12 rep range"),
                ("Leg Press", 3, 12, ""),
                ("Leg Curls", 3, 15, ""),
                ("Calf Raises", 4, 20, ""),
            ]),
        ]

        plan.days = daysData.map { weekday, label, exercises in
            let day = DayRoutine(weekday: weekday, label: label)
            day.exercises = exercises.map {
                Exercise(name: $0.0, targetSets: $0.1, targetReps: $0.2, notes: $0.3)
            }
            return day
        }

        modelContext.insert(plan)
    }
}
