import SwiftUI

struct ExercisePickerView: View {
    let onSelect: (ExerciseDBItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @AppStorage("exerciseDBApiKey") private var apiKey = ""

    @State private var searchText = ""
    @State private var selectedBodyPart: String? = nil
    @State private var exercises: [ExerciseDBItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                bodyPartFilters
                Divider()
                content
            }
            .navigationTitle("Browse Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search by name")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onSubmit(of: .search) { triggerSearch() }
            .onChange(of: searchText) { _, new in if new.isEmpty { triggerSearch() } }
            .onChange(of: selectedBodyPart) { triggerSearch() }
            .onAppear { triggerSearch() }
        }
    }

    private var bodyPartFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", selected: selectedBodyPart == nil) {
                    selectedBodyPart = nil
                }
                ForEach(ExerciseDBService.bodyParts, id: \.self) { part in
                    filterChip(label: part.capitalized, selected: selectedBodyPart == part) {
                        toggleBodyPart(part)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func toggleBodyPart(_ part: String) {
        selectedBodyPart = selectedBodyPart == part ? nil : part
    }

    @ViewBuilder
    private var content: some View {
        if apiKey.isEmpty {
            noApiKeyView
        } else if isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.orange)
                Text(error).multilineTextAlignment(.center).foregroundStyle(.secondary)
                Button("Retry") { triggerSearch() }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if exercises.isEmpty {
            ContentUnavailableView("No Exercises Found", systemImage: "magnifyingglass", description: Text("Try a different search or filter."))
        } else {
            List(exercises) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        if let url = URL(string: item.gifUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.15)
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name.capitalized).font(.headline).foregroundStyle(.primary)
                            HStack(spacing: 6) {
                                tag(item.bodyPart.capitalized, color: .blue)
                                tag(item.target.capitalized, color: .green)
                                tag(item.equipment.capitalized, color: .orange)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
        }
    }

    private var noApiKeyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.slash").font(.system(size: 48)).foregroundStyle(.secondary)
            Text("API Key Required")
                .font(.title3.bold())
            Text("Add your RapidAPI ExerciseDB key in Profile → API Keys to browse exercises.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func filterChip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selected ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundStyle(selected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func tag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func triggerSearch() {
        guard !apiKey.isEmpty else { return }
        errorMessage = nil
        isLoading = true
        Task {
            do {
                if !searchText.isEmpty {
                    exercises = try await ExerciseDBService.shared.search(searchText, apiKey: apiKey)
                } else if let part = selectedBodyPart {
                    exercises = try await ExerciseDBService.shared.fetchByBodyPart(part, apiKey: apiKey)
                } else {
                    exercises = try await ExerciseDBService.shared.fetchAll(apiKey: apiKey)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
