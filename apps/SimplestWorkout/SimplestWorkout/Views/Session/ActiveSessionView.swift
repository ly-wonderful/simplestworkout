import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("weightUnit") private var weightUnit = "lbs"

    let planName: String
    let dayRoutine: DayRoutine

    @State private var exerciseLogs: [ExerciseLog] = []
    @State private var showingFinishAlert = false
    @State private var startTime = Date()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.accentColor)
                        TimelineView(.periodic(from: startTime, by: 1)) { context in
                            Text(formatTime(context.date.timeIntervalSince(startTime)))
                                .monospacedDigit()
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Text(dayRoutine.weekday.shortName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                ForEach(exerciseLogs.indices, id: \.self) { exIdx in
                    Section(header: HStack {
                        Text(exerciseLogs[exIdx].name)
                        Spacer()
                        Button {
                            searchExercise(exerciseLogs[exIdx].name)
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .textCase(nil)
                    }) {
                        ForEach(exerciseLogs[exIdx].sets.indices, id: \.self) { setIdx in
                            let lastReps = exerciseLogs[exIdx].sets[setIdx].lastReps
                            let lastWeight = exerciseLogs[exIdx].sets[setIdx].lastWeight
                            HStack {
                                Text("Set \(setIdx + 1)")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .frame(width: 50, alignment: .leading)
                                Spacer()
                                TextField(
                                    "Reps",
                                    value: $exerciseLogs[exIdx].sets[setIdx].reps,
                                    format: .number,
                                    prompt: Text(lastReps.map { "\($0)" } ?? "0")
                                        .foregroundStyle(.tertiary)
                                )
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 55)
                                Text("reps")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .frame(width: 30)
                                TextField(
                                    "Weight",
                                    value: $exerciseLogs[exIdx].sets[setIdx].weight,
                                    format: .number,
                                    prompt: Text(lastWeight.map { formatWeight($0) } ?? "0")
                                        .foregroundStyle(.tertiary)
                                )
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                                Text(weightUnit)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .frame(width: 26, alignment: .leading)
                            }
                        }
                        Button {
                            exerciseLogs[exIdx].sets.append(SetDraft())
                        } label: {
                            Label("Add Set", systemImage: "plus.circle")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .customBackground()
            .navigationTitle(planName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") { showingFinishAlert = true }
                        .fontWeight(.semibold)
                }
            }
            .alert("Finish Workout?", isPresented: $showingFinishAlert) {
                Button("Save") { saveSession() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your session will be saved to history.")
            }
        }
        .onAppear { setupLogs() }
    }

    private func setupLogs() {
        startTime = Date()

        let lastExercises = fetchLastSession()?.loggedExercises ?? []

        exerciseLogs = dayRoutine.exercises.map { ex in
            let lastEx = lastExercises.first { $0.exerciseName == ex.name }
            let sets = (0..<ex.targetSets).map { setIdx -> SetDraft in
                let lastSet = lastEx.flatMap { $0.sets.indices.contains(setIdx) ? $0.sets[setIdx] : nil }
                return SetDraft(lastReps: lastSet?.reps, lastWeight: lastSet?.weight)
            }
            return ExerciseLog(name: ex.name, sets: sets)
        }
    }

    private func fetchLastSession() -> WorkoutSession? {
        let routineId = dayRoutine.id
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.planId == routineId },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    private func saveSession() {
        let session = WorkoutSession(planId: dayRoutine.id, planName: planName)
        session.startedAt = startTime
        session.completedAt = Date()
        session.loggedExercises = exerciseLogs.map { log in
            let le = LoggedExercise(exerciseName: log.name)
            le.sets = log.sets.map { draft in
                LoggedSet(
                    reps: draft.reps ?? draft.lastReps ?? 0,
                    weight: draft.weight ?? draft.lastWeight ?? 0
                )
            }
            return le
        }
        modelContext.insert(session)
        dismiss()
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        let hrs = total / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    private func formatWeight(_ w: Double) -> String {
        w.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(w))" : String(format: "%.1f", w)
    }

    private func searchExercise(_ name: String) {
        let query = "\(name) exercise form".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        if let url = URL(string: "https://www.google.com/search?tbm=isch&q=\(query)") {
            openURL(url)
        }
    }
}

struct ExerciseLog {
    var name: String
    var sets: [SetDraft]
}

struct SetDraft {
    var reps: Int?
    var weight: Double?
    var lastReps: Int?
    var lastWeight: Double?
}
