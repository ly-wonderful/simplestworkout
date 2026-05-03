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
        }
        .onChange(of: sessionViewModel.isComplete) { _, complete in
            if complete { dismiss() }
        }
    }

    @ViewBuilder
    private func exerciseSection(exercise: LoggedExercise) -> some View {
        Section(exercise.exerciseName) {
            if exercise.sets.isEmpty {
                Text("No sets logged yet.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(exercise.sets) { set in
                    HStack {
                        Text("\(set.reps) reps")
                        Spacer()
                        Text(String(format: "%.1f lbs", set.weight))
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
        }
    }

    private func logSet(for exercise: LoggedExercise) {
        let repsVal = reps[exercise.id] ?? 10
        guard repsVal > 0 else { return }
        let weightVal = Double(weights[exercise.id] ?? "") ?? 0
        sessionViewModel.addSet(to: exercise, reps: repsVal, weight: weightVal)
    }
}
