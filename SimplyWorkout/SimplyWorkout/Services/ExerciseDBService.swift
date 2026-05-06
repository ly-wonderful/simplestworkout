import Foundation

struct ExerciseDBItem: Decodable, Identifiable {
    let id: String
    let name: String
    let bodyPart: String
    let equipment: String
    let target: String
    let gifUrl: String
}

final class ExerciseDBService {
    static let shared = ExerciseDBService()
    private init() {}

    private let baseURL = "https://exercisedb.p.rapidapi.com"
    private let host = "exercisedb.p.rapidapi.com"

    static let bodyParts = [
        "back", "cardio", "chest", "lower arms", "lower legs",
        "neck", "shoulders", "upper arms", "upper legs", "waist"
    ]

    func fetchByBodyPart(_ bodyPart: String, apiKey: String, limit: Int = 50) async throws -> [ExerciseDBItem] {
        let encoded = bodyPart.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? bodyPart
        let url = URL(string: "\(baseURL)/exercises/bodyPart/\(encoded)?limit=\(limit)")!
        return try await fetch(url: url, apiKey: apiKey)
    }

    func search(_ query: String, apiKey: String, limit: Int = 30) async throws -> [ExerciseDBItem] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
        let url = URL(string: "\(baseURL)/exercises/name/\(encoded)?limit=\(limit)")!
        return try await fetch(url: url, apiKey: apiKey)
    }

    func fetchAll(apiKey: String, limit: Int = 100) async throws -> [ExerciseDBItem] {
        let url = URL(string: "\(baseURL)/exercises?limit=\(limit)")!
        return try await fetch(url: url, apiKey: apiKey)
    }

    private func fetch(url: URL, apiKey: String) async throws -> [ExerciseDBItem] {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(host, forHTTPHeaderField: "x-rapidapi-host")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ExerciseDBError.badResponse
        }
        return try JSONDecoder().decode([ExerciseDBItem].self, from: data)
    }
}

enum ExerciseDBError: LocalizedError {
    case badResponse
    var errorDescription: String? {
        switch self {
        case .badResponse: return "Invalid response from ExerciseDB. Check your API key."
        }
    }
}
