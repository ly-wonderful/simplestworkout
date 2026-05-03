import Foundation
import Observation

@Observable
@MainActor
final class HistoryViewModel {
    var sessions: [WorkoutSession] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let dataStore: DataStore
    let userId: String

    init(dataStore: DataStore, userId: String) {
        self.dataStore = dataStore
        self.userId = userId
    }

    func loadSessions() {
        isLoading = true
        errorMessage = nil
        do {
            sessions = try dataStore.fetchSessions(for: userId)
        } catch {
            errorMessage = "Failed to load history."
        }
        isLoading = false
    }

    func deleteSession(_ session: WorkoutSession) {
        do {
            try dataStore.deleteSession(session)
            loadSessions()
        } catch {
            errorMessage = "Failed to delete session."
        }
    }
}
