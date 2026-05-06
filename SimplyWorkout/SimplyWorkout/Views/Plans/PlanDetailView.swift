import SwiftUI

struct PlanDetailView: View {
    let plan: WorkoutPlan
    let plansViewModel: PlansViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var showEditor = false
    @State private var showSession = false
    @State private var showDeleteAlert = false
    @State private var sessionViewModel: SessionViewModel?
    @Environment(\.dismiss) private var dismiss

    @AppStorage("exerciseDBApiKey") private var apiKey = ""
    @State private var enrichments: [String: ExerciseDBItem] = [:]
    @State private var isFetching = false
    @State private var selection: ExerciseSelection? = nil

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
                    Button {
                        let key = exercise.name.lowercased()
                        selection = ExerciseSelection(id: key, exercise: exercise, info: enrichments[key])
                    } label: {
                        exerciseRow(exercise)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(plan.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if isFetching {
                        ProgressView().scaleEffect(0.8)
                    }
                    Menu {
                        Button("Edit") { showEditor = true }
                        Button("Delete Plan", role: .destructive) { showDeleteAlert = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Delete \"\(plan.name)\"?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                plansViewModel.deletePlan(plan)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This plan will be permanently deleted.")
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
        .sheet(item: $selection) { sel in
            ExerciseDetailSheet(exercise: sel.exercise, info: sel.info)
        }
        .sheet(isPresented: $showEditor) {
            PlanEditorView(mode: .edit(plan), plansViewModel: plansViewModel)
        }
        .fullScreenCover(isPresented: $showSession) {
            if let svm = sessionViewModel {
                ActiveSessionView(sessionViewModel: svm)
            }
        }
        .onAppear { fetchEnrichments() }
        .onChange(of: showEditor) { _, isShowing in
            if !isShowing { fetchEnrichments() }
        }
    }

    @ViewBuilder
    private func exerciseRow(_ exercise: Exercise) -> some View {
        let key = exercise.name.lowercased()
        let info = enrichments[key]
        HStack(spacing: 12) {
            if let info, let url = URL(string: info.gifUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if isFetching {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name).font(.headline)
                Text("\(exercise.targetSets) sets × \(exercise.targetReps) reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes).font(.caption).foregroundStyle(.tertiary)
                }
                if let info {
                    HStack(spacing: 6) {
                        dbTag(info.bodyPart.capitalized, color: .blue)
                        dbTag(info.target.capitalized, color: .green)
                        dbTag(info.equipment.capitalized, color: .orange)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func dbTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func fetchEnrichments() {
        guard !apiKey.isEmpty, !plan.exercises.isEmpty else { return }
        isFetching = true
        Task {
            await withTaskGroup(of: (String, ExerciseDBItem?).self) { group in
                for exercise in plan.exercises {
                    let name = exercise.name
                    group.addTask {
                        let result = try? await ExerciseDBService.shared.search(name, apiKey: apiKey, limit: 1)
                        return (name.lowercased(), result?.first)
                    }
                }
                for await (key, item) in group {
                    if let item { enrichments[key] = item }
                }
            }
            isFetching = false
        }
    }
}

private struct ExerciseSelection: Identifiable {
    let id: String
    let exercise: Exercise
    let info: ExerciseDBItem?
}
