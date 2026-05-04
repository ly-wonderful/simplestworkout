import SwiftUI
import Charts

struct WeightTrackerView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var vm: WeightViewModel?
    @State private var showForm = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    content(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showForm.toggle() } label: {
                        Image(systemName: showForm ? "xmark" : "plus")
                    }
                }
            }
        }
        .onAppear {
            let uid = authViewModel.currentUserId
            guard !uid.isEmpty else { return }
            if vm?.userId != uid {
                vm = WeightViewModel(dataStore: dataStore, userId: uid)
            }
            vm?.load()
        }
    }

    @ViewBuilder
    private func content(vm: WeightViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if showForm {
                    LogWeightForm(vm: vm, onSave: { showForm = false })
                }
                statsRow(vm: vm)
                if !vm.weightLogs.isEmpty {
                    weightChart(vm: vm)
                    historyList(vm: vm)
                } else if !showForm {
                    ContentUnavailableView(
                        "No Weight Entries",
                        systemImage: "scalemass",
                        description: Text("Tap + to log your first weight.")
                    )
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func statsRow(vm: WeightViewModel) -> some View {
        HStack(spacing: 12) {
            miniStat(label: "Current", value: vm.currentWeight.map { String(format: "%.1f lbs", $0.weight) } ?? "—")
            Divider().frame(height: 36)
            miniStat(label: "Starting", value: vm.startingWeight.map { String(format: "%.1f lbs", $0.weight) } ?? "—")
            Divider().frame(height: 36)
            if let change = vm.totalChange {
                miniStat(
                    label: "Change",
                    value: String(format: "%+.1f lbs", change),
                    valueColor: change < 0 ? .green : .red
                )
            } else {
                miniStat(label: "Change", value: "—")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func miniStat(label: String, value: String, valueColor: Color = .primary) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.subheadline.bold()).foregroundStyle(valueColor)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func weightChart(vm: WeightViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trend").font(.headline)
            let sorted = vm.weightLogs.sorted { $0.date < $1.date }
            Chart(sorted) { log in
                AreaMark(x: .value("Date", log.date), y: .value("lbs", log.weight))
                    .foregroundStyle(.teal.opacity(0.25))
                LineMark(x: .value("Date", log.date), y: .value("lbs", log.weight))
                    .foregroundStyle(.teal)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(x: .value("Date", log.date), y: .value("lbs", log.weight))
                    .foregroundStyle(.teal)
                    .symbolSize(30)
            }
            .frame(height: 160)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func historyList(vm: WeightViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History").font(.headline)
            ForEach(vm.weightLogs) { log in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f lbs", log.weight)).font(.subheadline.bold())
                        Text(log.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let notes = log.notes, !notes.isEmpty {
                        Text(notes).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Button(role: .destructive) {
                        vm.deleteLog(log)
                    } label: {
                        Image(systemName: "trash").font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                if log.id != vm.weightLogs.last?.id { Divider() }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct LogWeightForm: View {
    let vm: WeightViewModel
    let onSave: () -> Void
    @State private var weight: String = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Log Weight").font(.headline)

            HStack(spacing: 12) {
                TextField("lbs", text: $weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
            }

            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error).font(.caption).foregroundStyle(.red)
            }

            Button("Save") {
                guard let value = Double(weight), value > 0 else {
                    errorMessage = "Enter a valid weight."
                    return
                }
                do {
                    try vm.logWeight(weight: value, date: date, notes: notes.isEmpty ? nil : notes)
                    onSave()
                } catch {
                    errorMessage = "Failed to save."
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
