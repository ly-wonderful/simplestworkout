import Foundation
import Observation

@Observable
@MainActor
final class SessionViewModel {
    var currentSession: WorkoutSession?
    var isComplete: Bool = false
    var errorMessage: String? = nil

    private let dataStore: DataStore
    private let userId: String

    init(dataStore: DataStore, userId: String) {
        self.dataStore = dataStore
        self.userId = userId
    }

    func startSession(from plan: WorkoutPlan) {
        let session = WorkoutSession(userId: userId, planId: plan.id, planName: plan.name)
        for exercise in plan.exercises {
            session.loggedExercises.append(LoggedExercise(exerciseName: exercise.name))
        }
        currentSession = session
    }

    func addSet(to exercise: LoggedExercise, reps: Int, weight: Double) {
        exercise.sets.append(LoggedSet(reps: reps, weight: weight))
    }

    func removeSet(from exercise: LoggedExercise, at offsets: IndexSet) {
        exercise.sets.remove(atOffsets: offsets)
    }

    func completeSession() {
        guard let session = currentSession else { return }
        session.completedAt = Date()
        do {
            try dataStore.insertSession(session)
            currentSession = nil
            isComplete = true
        } catch {
            errorMessage = "Failed to save session."
        }
    }
}
