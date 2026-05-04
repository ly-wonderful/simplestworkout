import Foundation

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var label: String {
        switch self {
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        case .sunday:    return "Sunday"
        }
    }
}
