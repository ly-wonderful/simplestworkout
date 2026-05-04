import Foundation
import Observation

struct WeekDay: Identifiable {
    let id = UUID()
    let date: Date
    let hasWorkout: Bool
}

@Observable
@MainActor
final class DashboardViewModel {
    var sessions: [WorkoutSession] = []
    var weightLogs: [WeightLog] = []
    var isLoading = false

    let userId: String
    private let dataStore: DataStore

    init(dataStore: DataStore, userId: String) {
        self.dataStore = dataStore
        self.userId = userId
    }

    func load() {
        isLoading = true
        do {
            sessions = try dataStore.fetchSessions(for: userId)
            weightLogs = try dataStore.fetchWeightLogs(for: userId)
        } catch {}
        isLoading = false
    }

    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.completedAt != nil }
    }

    var thisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return completedSessions.filter { session in
            guard let completed = session.completedAt else { return false }
            return calendar.isDate(completed, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }

    var totalCompleted: Int { completedSessions.count }

    var currentWeight: WeightLog? { weightLogs.first }

    var weightDelta: Double? {
        guard weightLogs.count >= 2 else { return nil }
        return weightLogs[0].weight - weightLogs[1].weight
    }

    var streakWeeks: Int {
        let calendar = Calendar.current
        var streak = 0
        for weekOffset in 0..<52 {
            guard let ref = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()),
                  let interval = calendar.dateInterval(of: .weekOfYear, for: ref) else { break }
            let hasWorkout = completedSessions.contains {
                guard let c = $0.completedAt else { return false }
                return interval.contains(c)
            }
            if hasWorkout { streak += 1 } else { break }
        }
        return streak
    }

    var weekDayCompletions: [WeekDay] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        var days: [WeekDay] = []
        var current = interval.start
        while days.count < 7 && current < interval.end {
            let hasWorkout = completedSessions.contains {
                guard let c = $0.completedAt else { return false }
                return calendar.isDate(c, inSameDayAs: current)
            }
            days.append(WeekDay(date: current, hasWorkout: hasWorkout))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(86400)
        }
        return days
    }

    var recentSessions: [WorkoutSession] { Array(completedSessions.prefix(3)) }
}
