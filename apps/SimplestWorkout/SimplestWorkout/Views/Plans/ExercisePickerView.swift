import SwiftUI

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void

    @State private var searchText = ""
    @State private var exercises: [ExerciseEntry] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && exercises.isEmpty {
                    ProgressView("Loading exercises…")
                } else if let error = errorMessage, exercises.isEmpty {
                    ContentUnavailableView(
                        "Failed to Load",
                        systemImage: "wifi.slash",
                        description: Text(error)
                    )
                } else {
                    List(filtered) { exercise in
                        Button {
                            onSelect(exercise.name)
                            dismiss()
                        } label: {
                            Text(exercise.name)
                                .foregroundStyle(.primary)
                        }
                    }
                    .overlay {
                        if filtered.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task { await loadExercises() }
    }

    private var filtered: [ExerciseEntry] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty { return exercises }
        return exercises.filter { $0.name.lowercased().contains(query) }
    }

    private func loadExercises() async {
        do {
            try await ExerciseService.shared.loadAllIfNeeded()
            exercises = try await ExerciseService.shared.search("")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
