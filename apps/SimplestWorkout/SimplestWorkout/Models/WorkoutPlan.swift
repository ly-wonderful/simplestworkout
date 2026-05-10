import Foundation
import SwiftData

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: "Sun"
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: "Sunday"
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        }
    }

    static var today: Weekday {
        let cal = Calendar.current.component(.weekday, from: Date())
        return Weekday(rawValue: cal) ?? .sunday
    }
}

@Model final class WorkoutPlan {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var days: [DayRoutine]
    var createdAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.days = []
        self.createdAt = Date()
    }

    var sortedDays: [DayRoutine] {
        days.sorted { $0.weekday.rawValue < $1.weekday.rawValue }
    }

    func routine(for weekday: Weekday) -> DayRoutine? {
        days.first { $0.weekday == weekday }
    }
}
