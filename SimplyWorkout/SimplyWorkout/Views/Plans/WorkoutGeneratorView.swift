import SwiftUI

struct WorkoutGeneratorView: View {
    let plansViewModel: PlansViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var daysPerWeek = 3
    @State private var errorMessage: String? = nil

    private var templates: [WorkoutTemplate] {
        WorkoutGenerator.templates(for: daysPerWeek)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Days per week", selection: $daysPerWeek) {
                        ForEach(2...6, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Days per week")
                } footer: {
                    Text("\(templates.count) plans will be added to your list.")
                }

                Section("Plans to create") {
                    ForEach(templates) { template in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name).font(.headline)
                                Text(template.exercises.map(\.name).joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            if let day = template.dayOfWeek {
                                Text(day.label)
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }
                }
            }
            .navigationTitle("Generate Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Plans") { generate() }.bold()
                }
            }
        }
    }

    private func generate() {
        do {
            try plansViewModel.generatePlans(from: templates)
            dismiss()
        } catch {
            errorMessage = "Failed to generate plans."
        }
    }
}

private enum WorkoutGenerator {
    static func templates(for days: Int) -> [WorkoutTemplate] {
        switch days {
        case 2: return [
            fullBodyA.on(.monday), fullBodyB.on(.thursday)
        ]
        case 3: return [
            push.on(.monday), pull.on(.wednesday), legs.on(.friday)
        ]
        case 4: return [
            upperA.on(.monday), lowerA.on(.tuesday), upperB.on(.thursday), lowerB.on(.friday)
        ]
        case 5: return [
            push.on(.monday), pull.on(.tuesday), legs.on(.wednesday), upperA.on(.thursday), lowerA.on(.friday)
        ]
        case 6: return [
            pushA.on(.monday), pullA.on(.tuesday), legsA.on(.wednesday),
            pushB.on(.thursday), pullB.on(.friday), legsB.on(.saturday)
        ]
        default: return [push.on(.monday), pull.on(.wednesday), legs.on(.friday)]
        }
    }

    // MARK: Full Body (2 days)
    static let fullBodyA = WorkoutTemplate(name: "Full Body A", exercises: [
        ex("Squat", 4, 8),
        ex("Bench Press", 4, 8),
        ex("Barbell Row", 4, 8),
        ex("Overhead Press", 3, 10),
        ex("Romanian Deadlift", 3, 10),
    ])
    static let fullBodyB = WorkoutTemplate(name: "Full Body B", exercises: [
        ex("Deadlift", 4, 5),
        ex("Incline Dumbbell Press", 4, 10),
        ex("Lat Pulldown", 4, 10),
        ex("Dumbbell Shoulder Press", 3, 12),
        ex("Leg Press", 3, 12),
        ex("Bicep Curl", 3, 12),
    ])

    // MARK: Push / Pull / Legs (3 days, also used in 5-day)
    static let push = WorkoutTemplate(name: "Push Day", exercises: [
        ex("Bench Press", 4, 8),
        ex("Overhead Press", 3, 10),
        ex("Incline Dumbbell Press", 3, 10),
        ex("Tricep Pushdown", 3, 12),
        ex("Lateral Raises", 3, 15),
    ])
    static let pull = WorkoutTemplate(name: "Pull Day", exercises: [
        ex("Barbell Row", 4, 8),
        ex("Lat Pulldown", 3, 10),
        ex("Cable Row", 3, 12),
        ex("Bicep Curl", 3, 12),
        ex("Face Pulls", 3, 15),
    ])
    static let legs = WorkoutTemplate(name: "Leg Day", exercises: [
        ex("Squat", 4, 8),
        ex("Romanian Deadlift", 3, 10),
        ex("Leg Press", 3, 12),
        ex("Leg Curl", 3, 12),
        ex("Calf Raises", 4, 15),
    ])

    // MARK: Upper / Lower (4 days, also used in 5-day)
    static let upperA = WorkoutTemplate(name: "Upper A", exercises: [
        ex("Bench Press", 4, 8),
        ex("Barbell Row", 4, 8),
        ex("Overhead Press", 3, 10),
        ex("Lat Pulldown", 3, 10),
        ex("Bicep Curl", 3, 12),
        ex("Tricep Pushdown", 3, 12),
    ])
    static let lowerA = WorkoutTemplate(name: "Lower A", exercises: [
        ex("Squat", 4, 8),
        ex("Romanian Deadlift", 3, 10),
        ex("Leg Press", 3, 12),
        ex("Leg Curl", 3, 12),
        ex("Calf Raises", 4, 15),
    ])
    static let upperB = WorkoutTemplate(name: "Upper B", exercises: [
        ex("Incline Dumbbell Press", 4, 10),
        ex("Cable Row", 4, 10),
        ex("Dumbbell Shoulder Press", 3, 12),
        ex("Face Pulls", 3, 12),
        ex("Hammer Curl", 3, 12),
        ex("Overhead Tricep Extension", 3, 12),
    ])
    static let lowerB = WorkoutTemplate(name: "Lower B", exercises: [
        ex("Front Squat", 4, 8),
        ex("Deadlift", 3, 5),
        ex("Hack Squat", 3, 10),
        ex("Leg Extension", 3, 12),
        ex("Seated Calf Raises", 4, 15),
    ])

    // MARK: PPL x2 (6 days)
    static let pushA = WorkoutTemplate(name: "Push A", exercises: [
        ex("Bench Press", 4, 8),
        ex("Overhead Press", 3, 10),
        ex("Incline Dumbbell Press", 3, 10),
        ex("Tricep Pushdown", 3, 12),
        ex("Lateral Raises", 3, 15),
    ])
    static let pullA = WorkoutTemplate(name: "Pull A", exercises: [
        ex("Barbell Row", 4, 8),
        ex("Lat Pulldown", 3, 10),
        ex("Cable Row", 3, 12),
        ex("Bicep Curl", 3, 12),
        ex("Face Pulls", 3, 15),
    ])
    static let legsA = WorkoutTemplate(name: "Legs A", exercises: [
        ex("Squat", 4, 8),
        ex("Romanian Deadlift", 3, 10),
        ex("Leg Press", 3, 12),
        ex("Leg Curl", 3, 12),
        ex("Calf Raises", 4, 15),
    ])
    static let pushB = WorkoutTemplate(name: "Push B", exercises: [
        ex("Incline Dumbbell Press", 4, 10),
        ex("Dumbbell Shoulder Press", 3, 12),
        ex("Cable Fly", 3, 15),
        ex("Overhead Tricep Extension", 3, 12),
        ex("Lateral Raises", 4, 15),
    ])
    static let pullB = WorkoutTemplate(name: "Pull B", exercises: [
        ex("Deadlift", 4, 5),
        ex("Seated Cable Row", 4, 10),
        ex("Single-arm Dumbbell Row", 3, 10),
        ex("Hammer Curl", 3, 12),
        ex("Rear Delt Fly", 3, 15),
    ])
    static let legsB = WorkoutTemplate(name: "Legs B", exercises: [
        ex("Front Squat", 4, 8),
        ex("Hack Squat", 3, 10),
        ex("Walking Lunges", 3, 12),
        ex("Leg Extension", 3, 15),
        ex("Seated Calf Raises", 4, 15),
    ])

    private static func ex(_ name: String, _ sets: Int, _ reps: Int) -> ExerciseDraft {
        ExerciseDraft(name: name, targetSets: sets, targetReps: reps)
    }
}

private extension WorkoutTemplate {
    func on(_ day: DayOfWeek) -> WorkoutTemplate {
        WorkoutTemplate(name: name, exercises: exercises, dayOfWeek: day)
    }
}
