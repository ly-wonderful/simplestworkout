import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var targetSets: Int
    var targetReps: Int
    var notes: String?

    init(name: String, targetSets: Int, targetReps: Int, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.notes = notes
    }
}
