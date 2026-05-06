import SwiftUI

struct ActiveSessionView: View {
    let sessionViewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showFinishAlert = false
    @State private var reps: [UUID: Int] = [:]
    @State private var weights: [UUID: String] = [:]

    var body: some View {
        NavigationStack {
            Group {
                if let session = sessionViewModel.currentSession {
                    List {
                        ForEach(session.loggedExercises) { exercise in
                            exerciseSection(exercise: exercise)
                        }
                        wrapUpSection
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(sessionViewModel.currentSession?.planName ?? "Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish") { showFinishAlert = true }
                        .bold()
                        .foregroundStyle(.green)
                }
            }
            .alert("Finish Workout?", isPresented: $showFinishAlert) {
                Button("Finish") {
                    sessionViewModel.completeSession()
                }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("Mark this workout as complete and save it?")
            }
            .interactiveDismissDisabled()
            .onAppear { prefillFromLastSession() }
        }
        .onChange(of: sessionViewModel.isComplete) { _, complete in
            if complete { dismiss() }
        }
    }

    @ViewBuilder
    private func exerciseSection(exercise: LoggedExercise) -> some View {
        Section {
            lastSessionRow(for: exercise)

            if exercise.sets.isEmpty {
                Text("No sets logged yet.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(exercise.sets) { set in
                    HStack {
                        Text("\(set.reps) reps")
                        Spacer()
                        Text(set.weight == 0 ? "Bodyweight" : String(format: "%.1f lbs", set.weight))
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    sessionViewModel.removeSet(from: exercise, at: offsets)
                }
            }

            HStack(spacing: 12) {
                TextField("Reps", value: Binding(
                    get: { reps[exercise.id] ?? 10 },
                    set: { reps[exercise.id] = $0 }
                ), format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)

                TextField("lbs", text: Binding(
                    get: { weights[exercise.id] ?? "" },
                    set: { weights[exercise.id] = $0 }
                ))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

                Button("Log Set") { logSet(for: exercise) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        } header: {
            Text(exercise.exerciseName)
        }
    }

    @ViewBuilder
    private func lastSessionRow(for exercise: LoggedExercise) -> some View {
        if let sets = sessionViewModel.lastSets[exercise.exerciseName], !sets.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption2)
                    Text("Last session")
                        .font(.caption2.bold())
                }
                .foregroundStyle(.secondary)

                let summary = sets.map { set -> String in
                    let w = set.weight == 0 ? "BW" : String(format: "%.0f lbs", set.weight)
                    return "\(w) × \(set.reps)"
                }.joined(separator: "  ·  ")

                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
            .listRowBackground(Color.accentColor.opacity(0.06))
        }
    }

    @ViewBuilder
    private var wrapUpSection: some View {
        Section("Wrap Up") {
            Picker("Feeling", selection: Binding(
                get: { sessionViewModel.selectedFeeling },
                set: { sessionViewModel.selectedFeeling = $0 }
            )) {
                Text("Not rated").tag(Optional<WorkoutFeeling>.none)
                ForEach(WorkoutFeeling.allCases, id: \.self) { feeling in
                    Text("\(feeling.emoji) \(feeling.label)").tag(Optional(feeling))
                }
            }
            TextField("Session notes", text: Binding(
                get: { sessionViewModel.sessionNotes },
                set: { sessionViewModel.sessionNotes = $0 }
            ), axis: .vertical)
            .lineLimit(2...5)
        }
    }

    private func logSet(for exercise: LoggedExercise) {
        let repsVal = reps[exercise.id] ?? 10
        guard repsVal > 0 else { return }
        let weightVal = Double(weights[exercise.id] ?? "") ?? 0
        sessionViewModel.addSet(to: exercise, reps: repsVal, weight: weightVal)
    }

    private func prefillFromLastSession() {
        guard let session = sessionViewModel.currentSession else { return }
        for exercise in session.loggedExercises {
            guard let sets = sessionViewModel.lastSets[exercise.exerciseName],
                  let first = sets.first else { continue }
            if reps[exercise.id] == nil {
                reps[exercise.id] = first.reps
            }
            if weights[exercise.id] == nil {
                weights[exercise.id] = first.weight == 0 ? "" : String(format: "%.1f", first.weight)
            }
        }
    }
}
