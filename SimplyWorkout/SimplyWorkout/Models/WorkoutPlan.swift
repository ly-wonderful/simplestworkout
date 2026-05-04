import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    var id: UUID
    var userId: String
    var name: String
    var dayOfWeek: DayOfWeek?
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]

    init(userId: String, name: String, dayOfWeek: DayOfWeek? = nil) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.createdAt = Date()
        self.exercises = []
    }
}
