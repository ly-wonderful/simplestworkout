import Foundation

struct LoggedSet: Codable, Identifiable {
    var id: UUID = UUID()
    var reps: Int
    var weight: Double
}
