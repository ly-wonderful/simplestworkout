import Foundation
import Observation

@Observable
@MainActor
final class PlansViewModel {
    var plans: [WorkoutPlan] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let dataStore: DataStore
    let userId: String

    init(dataStore: DataStore, userId: String) {
        self.dataStore = dataStore
        self.userId = userId
    }

    func loadPlans() {
        isLoading = true
        errorMessage = nil
        do {
            plans = try dataStore.fetchPlans(for: userId)
        } catch {
            errorMessage = "Failed to load plans."
        }
        isLoading = false
    }

    func createPlan(name: String, exercises: [ExerciseDraft]) throws {
        let plan = WorkoutPlan(userId: userId, name: name)
        for draft in exercises {
            plan.exercises.append(Exercise(
                name: draft.name,
                targetSets: draft.targetSets,
                targetReps: draft.targetReps,
                notes: draft.notes.isEmpty ? nil : draft.notes
            ))
        }
        try dataStore.insertPlan(plan)
        loadPlans()
    }

    func updatePlan(_ plan: WorkoutPlan, name: String, exercises: [ExerciseDraft]) throws {
        plan.name = name
        plan.exercises.removeAll()
        for draft in exercises {
            plan.exercises.append(Exercise(
                name: draft.name,
                targetSets: draft.targetSets,
                targetReps: draft.targetReps,
                notes: draft.notes.isEmpty ? nil : draft.notes
            ))
        }
        try dataStore.save()
        loadPlans()
    }

    func deletePlan(_ plan: WorkoutPlan) {
        do {
            try dataStore.deletePlan(plan)
            loadPlans()
        } catch {
            errorMessage = "Failed to delete plan."
        }
    }

    func generatePlans(from templates: [WorkoutTemplate]) throws {
        for template in templates {
            let plan = WorkoutPlan(userId: userId, name: template.name)
            for draft in template.exercises {
                plan.exercises.append(Exercise(
                    name: draft.name,
                    targetSets: draft.targetSets,
                    targetReps: draft.targetReps,
                    notes: draft.notes.isEmpty ? nil : draft.notes
                ))
            }
            try dataStore.insertPlan(plan)
        }
        loadPlans()
    }
}

struct ExerciseDraft: Identifiable {
    var id = UUID()
    var name: String = ""
    var targetSets: Int = 3
    var targetReps: Int = 10
    var notes: String = ""
}

struct WorkoutTemplate: Identifiable {
    let id = UUID()
    let name: String
    let exercises: [ExerciseDraft]
}
