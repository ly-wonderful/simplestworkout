import Foundation
import SwiftData

@Model
final class LoggedExercise {
    var id: UUID
    var exerciseName: String
    var sets: [LoggedSet]

    init(exerciseName: String) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.sets = []
    }
}
