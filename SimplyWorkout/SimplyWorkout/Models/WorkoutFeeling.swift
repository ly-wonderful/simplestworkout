import Foundation

enum WorkoutFeeling: String, Codable, CaseIterable {
    case great, good, okay, bad, terrible

    var label: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .great:    return "😄"
        case .good:     return "🙂"
        case .okay:     return "😐"
        case .bad:      return "😕"
        case .terrible: return "😫"
        }
    }
}
