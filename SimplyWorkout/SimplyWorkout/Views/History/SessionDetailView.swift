import SwiftUI

struct SessionDetailView: View {
    let session: WorkoutSession

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Date", value: session.startedAt.formatted(date: .long, time: .shortened))
                LabeledContent("Duration", value: session.formattedDuration)
                LabeledContent("Exercises", value: "\(session.loggedExercises.count)")
            }

            ForEach(session.loggedExercises) { exercise in
                Section(exercise.exerciseName) {
                    if exercise.sets.isEmpty {
                        Text("No sets logged.").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                            HStack {
                                Text("Set \(index + 1)").foregroundStyle(.secondary)
                                Spacer()
                                Text("\(set.reps) reps")
                                Text("·").foregroundStyle(.secondary)
                                Text(String(format: "%.1f lbs", set.weight))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(session.planName)
    }
}
