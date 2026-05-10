import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.planName)
                                .font(.headline)
                            Text(session.startedAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(session.loggedExercises.count) exercise\(session.loggedExercises.count == 1 ? "" : "s") · \(totalSets(session)) sets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .customBackground()
            .navigationTitle("History")
            .navigationDestination(for: WorkoutSession.self) { session in
                SessionDetailView(session: session)
            }
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "clock",
                        description: Text("Completed sessions will appear here.")
                    )
                }
            }
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }

    private func totalSets(_ session: WorkoutSession) -> Int {
        session.loggedExercises.reduce(0) { $0 + $1.sets.count }
    }
}
