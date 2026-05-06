import SwiftUI

struct ExerciseDetailSheet: View {
    let exercise: Exercise
    let info: ExerciseDBItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    gifSection
                    infoSection
                }
                .padding()
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var gifSection: some View {
        if let info, let url = URL(string: info.gifUrl) {
            AnimatedGifView(url: url)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: 200)
                VStack(spacing: 8) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text("No preview available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                statBox(value: "\(exercise.targetSets)", label: "Sets")
                statBox(value: "\(exercise.targetReps)", label: "Reps")
            }

            if let info {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Muscle Info").font(.headline)
                    HStack(spacing: 8) {
                        metaTag(label: "Body Part", value: info.bodyPart.capitalized, color: .blue)
                        metaTag(label: "Target", value: info.target.capitalized, color: .green)
                    }
                    metaTag(label: "Equipment", value: info.equipment.capitalized, color: .orange)
                }
            }

            if let notes = exercise.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes").font(.headline)
                    Text(notes).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func metaTag(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(Capsule())
        }
    }
}
