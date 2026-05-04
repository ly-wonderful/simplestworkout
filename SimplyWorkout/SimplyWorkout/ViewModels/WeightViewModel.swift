import Foundation
import Observation

@Observable
@MainActor
final class WeightViewModel {
    var weightLogs: [WeightLog] = []
    var isLoading = false
    var errorMessage: String? = nil

    let userId: String
    private let dataStore: DataStore

    init(dataStore: DataStore, userId: String) {
        self.dataStore = dataStore
        self.userId = userId
    }

    func load() {
        isLoading = true
        do {
            weightLogs = try dataStore.fetchWeightLogs(for: userId)
        } catch {
            errorMessage = "Failed to load weight history."
        }
        isLoading = false
    }

    func logWeight(weight: Double, date: Date, notes: String?) throws {
        let log = WeightLog(userId: userId, weight: weight, unit: "lbs", date: date, notes: notes)
        try dataStore.insertWeightLog(log)
        load()
    }

    func deleteLog(_ log: WeightLog) {
        do {
            try dataStore.deleteWeightLog(log)
            load()
        } catch {
            errorMessage = "Failed to delete entry."
        }
    }

    var currentWeight: WeightLog? { weightLogs.first }
    var startingWeight: WeightLog? { weightLogs.last }

    var totalChange: Double? {
        guard let current = currentWeight?.weight,
              let start = startingWeight?.weight,
              weightLogs.count >= 2 else { return nil }
        return current - start
    }
}
