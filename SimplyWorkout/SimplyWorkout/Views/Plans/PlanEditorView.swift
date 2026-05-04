import SwiftUI

enum PlanEditorMode {
    case create
    case edit(WorkoutPlan)
}

struct PlanEditorView: View {
    let mode: PlanEditorMode
    let plansViewModel: PlansViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var selectedDay: DayOfWeek? = nil
    @State private var exercises: [ExerciseDraft] = []
    @State private var errorMessage: String? = nil

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Name") {
                    TextField("e.g. Push Day", text: $planName)
                    Picker("Day", selection: $selectedDay) {
                        Text("Unscheduled").tag(Optional<DayOfWeek>.none)
                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                            Text(day.label).tag(Optional(day))
                        }
                    }
                }

                Section("Exercises") {
                    ForEach($exercises) { $exercise in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Exercise Name", text: $exercise.name)
                                .font(.headline)
                            Stepper("Sets: \(exercise.targetSets)", value: $exercise.targetSets, in: 1...20)
                                .font(.subheadline)
                            Stepper("Reps: \(exercise.targetReps)", value: $exercise.targetReps, in: 1...100)
                                .font(.subheadline)
                            TextField("Notes (optional)", text: $exercise.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { exercises.remove(atOffsets: $0) }
                    .onMove { exercises.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        exercises.append(ExerciseDraft())
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                    }
                }
                .environment(\.editMode, .constant(.active))

                if let error = errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Plan" : "New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.bold()
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        guard case .edit(let plan) = mode else { return }
        planName = plan.name
        selectedDay = plan.dayOfWeek
        exercises = plan.exercises.map {
            ExerciseDraft(name: $0.name, targetSets: $0.targetSets, targetReps: $0.targetReps, notes: $0.notes ?? "")
        }
    }

    private func save() {
        guard !planName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Plan name is required."
            return
        }
        guard !exercises.isEmpty else {
            errorMessage = "Add at least one exercise."
            return
        }
        guard exercises.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }) else {
            errorMessage = "All exercises need a name."
            return
        }
        do {
            switch mode {
            case .create:
                try plansViewModel.createPlan(name: planName, exercises: exercises, dayOfWeek: selectedDay)
            case .edit(let plan):
                try plansViewModel.updatePlan(plan, name: planName, exercises: exercises, dayOfWeek: selectedDay)
            }
            dismiss()
        } catch {
            errorMessage = "Failed to save plan."
        }
    }
}
