import Foundation
import SwiftData

@Model final class WorkoutSession {
    var id: UUID
    var planId: UUID
    var planName: String
    var startedAt: Date
    var completedAt: Date?
    @Relationship(deleteRule: .cascade) var loggedExercises: [LoggedExercise]

    init(planId: UUID, planName: String) {
        self.id = UUID()
        self.planId = planId
        self.planName = planName
        self.startedAt = Date()
        self.completedAt = nil
        self.loggedExercises = []
    }
}
