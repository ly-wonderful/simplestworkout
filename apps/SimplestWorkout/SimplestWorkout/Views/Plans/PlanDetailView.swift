import SwiftUI
import SwiftData

struct PlanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let plan: WorkoutPlan
    @State private var showingEditor = false
    @State private var showingDeleteAlert = false
    @State private var selectedDay: DayRoutine?

    private var today: Weekday { .today }

    private var todayRoutine: DayRoutine? {
        plan.routine(for: today)
    }

    var body: some View {
        List {
            ForEach(plan.sortedDays) { day in
                let isToday = day.weekday == today
                Section {
                    ForEach(day.exercises) { exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .fontWeight(.medium)
                            Text("\(exercise.targetSets) sets × \(exercise.targetReps) reps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !exercise.notes.isEmpty {
                                Text(exercise.notes)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    if day.exercises.isEmpty {
                        Text("No exercises")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    if !isToday {
                        Button {
                            selectedDay = day
                        } label: {
                            Label("Start This Day", systemImage: "play.circle")
                                .font(.subheadline)
                        }
                        .disabled(day.exercises.isEmpty)
                    }
                } header: {
                    HStack {
                        Text(day.weekday.fullName)
                        if !day.label.isEmpty {
                            Text("– \(day.label)")
                        }
                        if isToday {
                            Text("TODAY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if plan.days.isEmpty {
                Section {
                    Text("No days configured. Tap Edit to set up your week.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
        .customBackground()
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEditor = true }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete", role: .destructive) { showingDeleteAlert = true }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let todayRoutine, !todayRoutine.exercises.isEmpty {
                Button {
                    selectedDay = todayRoutine
                } label: {
                    Label("Start Today's Workout – \(today.shortName)", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding()
                }
            } else if !plan.days.isEmpty {
                Text("Rest day – no routine for \(today.fullName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .sheet(isPresented: $showingEditor) {
            PlanEditorView(plan: plan)
        }
        .fullScreenCover(item: $selectedDay) { day in
            ActiveSessionView(planName: plan.name, dayRoutine: day)
        }
        .alert("Delete Plan", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(plan)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(plan.name)\" and all its routines.")
        }
    }
}
