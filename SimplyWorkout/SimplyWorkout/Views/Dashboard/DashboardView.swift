import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var vm: DashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    content(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Dashboard")
        }
        .onAppear {
            let uid = authViewModel.currentUserId
            guard !uid.isEmpty else { return }
            if vm?.userId != uid {
                vm = DashboardViewModel(dataStore: dataStore, userId: uid)
            }
            vm?.load()
        }
    }

    @ViewBuilder
    private func content(vm: DashboardViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                statsGrid(vm: vm)
                weeklyOverview(vm: vm)
                if !vm.weightLogs.isEmpty {
                    weightChart(vm: vm)
                }
                if !vm.recentSessions.isEmpty {
                    recentWorkouts(vm: vm)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func statsGrid(vm: DashboardViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "This Week", value: "\(vm.thisWeekCount)", icon: "flame.fill")
            StatCard(title: "All Time", value: "\(vm.totalCompleted)", icon: "checkmark.circle.fill")
            StatCard(title: "Streak", value: "\(vm.streakWeeks)w", icon: "bolt.fill")
            if let log = vm.currentWeight {
                StatCard(
                    title: "Weight",
                    value: String(format: "%.1f %@", log.weight, log.unit),
                    icon: "scalemass.fill",
                    delta: vm.weightDelta
                )
            } else {
                StatCard(title: "Weight", value: "—", icon: "scalemass.fill")
            }
        }
    }

    @ViewBuilder
    private func weeklyOverview(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Week").font(.headline)
            HStack(spacing: 6) {
                ForEach(vm.weekDayCompletions) { day in
                    let isToday = Calendar.current.isDateInToday(day.date)
                    VStack(spacing: 4) {
                        Text(day.date.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        ZStack {
                            Circle()
                                .fill(day.hasWorkout ? Color.accentColor : Color.secondary.opacity(0.15))
                            if isToday {
                                Circle().stroke(Color.accentColor, lineWidth: 2)
                            }
                        }
                        .frame(width: 34, height: 34)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func weightChart(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weight Trend").font(.headline)
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
            .frame(height: 140)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 4)) }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func recentWorkouts(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Workouts").font(.headline)
            ForEach(vm.recentSessions) { session in
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.planName).font(.subheadline).fontWeight(.medium)
                            HStack(spacing: 4) {
                                Text(session.startedAt.formatted(date: .abbreviated, time: .omitted))
                                Text("·")
                                Text(session.formattedDuration)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let feeling = session.feeling {
                            Text(feeling.emoji).font(.title3)
                        }
                    }
                    .padding(.vertical, 8)
                    if session.id != vm.recentSessions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var delta: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .foregroundStyle(.accent)
                Spacer()
                if let delta {
                    HStack(spacing: 2) {
                        Image(systemName: delta < 0 ? "arrow.down" : "arrow.up")
                        Text(String(format: "%.1f", abs(delta)))
                    }
                    .font(.caption2)
                    .foregroundStyle(delta < 0 ? .green : .red)
                }
            }
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
