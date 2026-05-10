import Foundation

struct ExerciseEntry: Identifiable, Hashable {
    let id: Int
    let name: String
}

actor ExerciseService {
    static let shared = ExerciseService()

    private let baseURL = "https://wger.de/api/v2/exercise-translation/"
    private let pageSize = 200
    private var allExercises: [ExerciseEntry] = []
    private var nextURL: String?
    private var isFullyLoaded = false

    func search(_ query: String) async throws -> [ExerciseEntry] {
        if allExercises.isEmpty {
            try await loadPage()
        }

        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return allExercises
        }

        let lowered = query.lowercased()
        return allExercises.filter { $0.name.lowercased().contains(lowered) }
    }

    func loadAllIfNeeded() async throws {
        if allExercises.isEmpty {
            try await loadPage()
        }
        while !isFullyLoaded {
            try await loadPage()
        }
    }

    private func loadPage() async throws {
        guard !isFullyLoaded else { return }

        let urlString: String
        if let next = nextURL {
            urlString = next
        } else {
            urlString = "\(baseURL)?format=json&language=2&ordering=name&limit=\(pageSize)"
        }

        guard let url = URL(string: urlString) else { return }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TranslationResponse.self, from: data)

        let newEntries = response.results.map { ExerciseEntry(id: $0.id, name: $0.name) }
        let existingIDs = Set(allExercises.map(\.id))
        let unique = newEntries.filter { !existingIDs.contains($0.id) }
        allExercises.append(contentsOf: unique)
        allExercises.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        nextURL = response.next
        if response.next == nil {
            isFullyLoaded = true
        }
    }
}

private struct TranslationResponse: Decodable {
    let count: Int
    let next: String?
    let results: [TranslationEntry]
}

private struct TranslationEntry: Decodable {
    let id: Int
    let name: String
}
