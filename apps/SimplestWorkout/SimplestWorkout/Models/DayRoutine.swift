import Foundation
import SwiftData

@Model final class DayRoutine {
    var id: UUID
    var weekday: Weekday
    var label: String
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]

    init(weekday: Weekday, label: String = "") {
        self.id = UUID()
        self.weekday = weekday
        self.label = label
        self.exercises = []
    }
}
