import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var userId: String
    var planId: UUID
    var planName: String
    var startedAt: Date
    var completedAt: Date?
    var feeling: WorkoutFeeling?
    var sessionNotes: String?
    @Relationship(deleteRule: .cascade) var loggedExercises: [LoggedExercise]

    init(userId: String, planId: UUID, planName: String) {
        self.id = UUID()
        self.userId = userId
        self.planId = planId
        self.planName = planName
        self.startedAt = Date()
        self.completedAt = nil
        self.feeling = nil
        self.sessionNotes = nil
        self.loggedExercises = []
    }

    var formattedDuration: String {
        guard let completedAt else { return "In progress" }
        let minutes = Int(completedAt.timeIntervalSince(startedAt) / 60)
        return "\(minutes) min"
    }
}
