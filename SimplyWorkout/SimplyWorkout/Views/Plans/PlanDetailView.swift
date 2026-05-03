import SwiftUI

struct PlanDetailView: View {
    let plan: WorkoutPlan
    let plansViewModel: PlansViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var showEditor = false
    @State private var showSession = false
    @State private var sessionViewModel: SessionViewModel?

    var body: some View {
        List {
            if plan.exercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises",
                    systemImage: "dumbbell",
                    description: Text("Edit this plan to add exercises.")
                )
            } else {
                ForEach(plan.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name).font(.headline)
                        Text("\(exercise.targetSets) sets × \(exercise.targetReps) reps")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let notes = exercise.notes, !notes.isEmpty {
                            Text(notes).font(.caption).foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(plan.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditor = true }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                let svm = SessionViewModel(dataStore: dataStore, userId: authViewModel.currentUserId)
                svm.startSession(from: plan)
                sessionViewModel = svm
                showSession = true
            } label: {
                Text("Start Workout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(plan.exercises.isEmpty ? Color.gray : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(plan.exercises.isEmpty)
            .padding()
            .background(.bar)
        }
        .sheet(isPresented: $showEditor) {
            PlanEditorView(mode: .edit(plan), plansViewModel: plansViewModel)
        }
        .fullScreenCover(isPresented: $showSession) {
            if let svm = sessionViewModel {
                ActiveSessionView(sessionViewModel: svm)
            }
        }
    }
}
