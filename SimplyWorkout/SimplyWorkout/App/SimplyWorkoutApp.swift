import SwiftUI
import SwiftData
import FirebaseCore

@main
struct SimplyWorkoutApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var dataStore: DataStore
    private let container: ModelContainer

    init() {
        FirebaseApp.configure()
        let schema = Schema([WorkoutPlan.self, Exercise.self, WorkoutSession.self, LoggedExercise.self])
        do {
            let c = try ModelContainer(for: schema)
            container = c
            _authViewModel = State(initialValue: AuthViewModel())
            _dataStore = State(initialValue: DataStore(context: c.mainContext))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(dataStore)
                .modelContainer(container)
        }
    }
}
