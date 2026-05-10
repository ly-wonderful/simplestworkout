import SwiftUI

struct SessionDetailView: View {
    @AppStorage("weightUnit") private var weightUnit = "lbs"
    let session: WorkoutSession

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Date", value: session.startedAt.formatted(date: .long, time: .shortened))
                if let completed = session.completedAt {
                    LabeledContent("Duration", value: duration(from: session.startedAt, to: completed))
                }
                LabeledContent("Exercises", value: "\(session.loggedExercises.count)")
            }

            ForEach(session.loggedExercises) { exercise in
                Section(exercise.exerciseName) {
                    ForEach(exercise.sets.indices, id: \.self) { i in
                        let set = exercise.sets[i]
                        HStack {
                            Text("Set \(i + 1)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Spacer()
                            Text("\(set.reps) reps")
                            if set.weight > 0 {
                                Text("· \(set.weight, specifier: "%.1f") \(weightUnit)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .customBackground()
        .navigationTitle(session.planName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func duration(from start: Date, to end: Date) -> String {
        let mins = Int(end.timeIntervalSince(start) / 60)
        return mins < 1 ? "< 1 min" : "\(mins) min"
    }
}
