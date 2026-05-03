import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    var id: UUID
    var userId: String
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]

    init(userId: String, name: String) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.createdAt = Date()
        self.exercises = []
    }
}
