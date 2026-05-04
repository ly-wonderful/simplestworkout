import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class DataStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Plans

    func fetchPlans(for userId: String) throws -> [WorkoutPlan] {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func insertPlan(_ plan: WorkoutPlan) throws {
        context.insert(plan)
        try context.save()
    }

    func deletePlan(_ plan: WorkoutPlan) throws {
        context.delete(plan)
        try context.save()
    }

    // MARK: - Sessions

    func fetchSessions(for userId: String) throws -> [WorkoutSession] {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func insertSession(_ session: WorkoutSession) throws {
        context.insert(session)
        try context.save()
    }

    func deleteSession(_ session: WorkoutSession) throws {
        context.delete(session)
        try context.save()
    }

    func save() throws {
        try context.save()
    }

    // MARK: - Weight Logs

    func fetchWeightLogs(for userId: String) throws -> [WeightLog] {
        let descriptor = FetchDescriptor<WeightLog>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func insertWeightLog(_ log: WeightLog) throws {
        context.insert(log)
        try context.save()
    }

    func deleteWeightLog(_ log: WeightLog) throws {
        context.delete(log)
        try context.save()
    }
}
