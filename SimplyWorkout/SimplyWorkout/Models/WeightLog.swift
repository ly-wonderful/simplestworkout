import Foundation
import SwiftData

@Model
final class WeightLog {
    var id: UUID
    var userId: String
    var date: Date
    var weight: Double
    var unit: String
    var notes: String?

    init(userId: String, weight: Double, unit: String = "lbs", date: Date = Date(), notes: String? = nil) {
        self.id = UUID()
        self.userId = userId
        self.date = date
        self.weight = weight
        self.unit = unit
        self.notes = notes
    }
}
