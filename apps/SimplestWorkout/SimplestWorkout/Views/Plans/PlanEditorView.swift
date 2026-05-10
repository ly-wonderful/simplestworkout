import SwiftUI
import SwiftData

struct PlanEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var plan: WorkoutPlan?

    @State private var name = ""
    @State private var dayDrafts: [DayDraft] = []
    @State private var showingExercisePicker = false
    @State private var pickerDayIndex = 0
    @State private var showingAddDay = false

    private var availableWeekdays: [Weekday] {
        let used = Set(dayDrafts.map(\.weekday))
        return Weekday.allCases.filter { !used.contains($0) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Name") {
                    TextField("e.g. PPL Program", text: $name)
                }

                ForEach(dayDrafts.indices, id: \.self) { dayIdx in
                    Section {
                        ForEach(dayDrafts[dayIdx].exercises.indices, id: \.self) { exIdx in
                            exerciseRow(dayIdx: dayIdx, exIdx: exIdx)
                        }
                        .onDelete { offsets in
                            dayDrafts[dayIdx].exercises.remove(atOffsets: offsets)
                        }

                        Button {
                            pickerDayIndex = dayIdx
                            showingExercisePicker = true
                        } label: {
                            Label("Browse Exercises", systemImage: "magnifyingglass")
                                .font(.subheadline)
                        }

                        Button {
                            dayDrafts[dayIdx].exercises.append(ExerciseDraft())
                        } label: {
                            Label("Add Custom", systemImage: "plus")
                                .font(.subheadline)
                        }
                    } header: {
                        HStack {
                            Text("\(dayDrafts[dayIdx].weekday.fullName)")
                            if !dayDrafts[dayIdx].label.isEmpty {
                                Text("– \(dayDrafts[dayIdx].label)")
                            }
                            Spacer()
                            Button(role: .destructive) {
                                dayDrafts.remove(at: dayIdx)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section {
                    if !availableWeekdays.isEmpty {
                        Button {
                            showingAddDay = true
                        } label: {
                            Label("Add Day", systemImage: "plus.circle")
                        }
                    }

                    if dayDrafts.isEmpty {
                        Text("Add days to build your weekly routine.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle(plan == nil ? "New Plan" : "Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Select Day", isPresented: $showingAddDay) {
                ForEach(availableWeekdays) { day in
                    Button(day.fullName) {
                        dayDrafts.append(DayDraft(weekday: day))
                        dayDrafts.sort { $0.weekday.rawValue < $1.weekday.rawValue }
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exerciseName in
                    dayDrafts[pickerDayIndex].exercises.append(ExerciseDraft(name: exerciseName))
                }
            }
        }
        .onAppear { loadExisting() }
    }

    @ViewBuilder
    private func exerciseRow(dayIdx: Int, exIdx: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Exercise name", text: $dayDrafts[dayIdx].exercises[exIdx].name)
                .fontWeight(.medium)
            HStack(spacing: 16) {
                HStack {
                    Text("Sets")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("\(dayDrafts[dayIdx].exercises[exIdx].targetSets)")
                        .font(.subheadline)
                        .monospacedDigit()
                    Stepper(
                        "\(dayDrafts[dayIdx].exercises[exIdx].targetSets)",
                        value: $dayDrafts[dayIdx].exercises[exIdx].targetSets,
                        in: 1...20
                    )
                    .labelsHidden()
                }
                HStack {
                    Text("Reps")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("\(dayDrafts[dayIdx].exercises[exIdx].targetReps)")
                        .font(.subheadline)
                        .monospacedDigit()
                    Stepper(
                        "\(dayDrafts[dayIdx].exercises[exIdx].targetReps)",
                        value: $dayDrafts[dayIdx].exercises[exIdx].targetReps,
                        in: 1...100
                    )
                    .labelsHidden()
                }
            }
            TextField("Notes (optional)", text: $dayDrafts[dayIdx].exercises[exIdx].notes)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func loadExisting() {
        guard let plan else { return }
        name = plan.name
        dayDrafts = plan.sortedDays.map { day in
            DayDraft(
                weekday: day.weekday,
                label: day.label,
                exercises: day.exercises.map {
                    ExerciseDraft(name: $0.name, targetSets: $0.targetSets, targetReps: $0.targetReps, notes: $0.notes)
                }
            )
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let plan {
            plan.name = trimmedName
            let oldDays = plan.days
            plan.days = dayDrafts.map { draft in
                let day = DayRoutine(weekday: draft.weekday, label: draft.label)
                day.exercises = draft.exercises.map {
                    Exercise(name: $0.name, targetSets: $0.targetSets, targetReps: $0.targetReps, notes: $0.notes)
                }
                return day
            }
            for old in oldDays {
                old.exercises.forEach { modelContext.delete($0) }
                modelContext.delete(old)
            }
        } else {
            let newPlan = WorkoutPlan(name: trimmedName)
            newPlan.days = dayDrafts.map { draft in
                let day = DayRoutine(weekday: draft.weekday, label: draft.label)
                day.exercises = draft.exercises.map {
                    Exercise(name: $0.name, targetSets: $0.targetSets, targetReps: $0.targetReps, notes: $0.notes)
                }
                return day
            }
            modelContext.insert(newPlan)
        }
        dismiss()
    }
}

struct DayDraft: Identifiable {
    var id = UUID()
    var weekday: Weekday
    var label: String = ""
    var exercises: [ExerciseDraft] = []
}

struct ExerciseDraft: Identifiable {
    var id = UUID()
    var name = ""
    var targetSets = 3
    var targetReps = 10
    var notes = ""
}
