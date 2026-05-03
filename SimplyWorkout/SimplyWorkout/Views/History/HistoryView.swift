import SwiftUI

struct HistoryView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var historyViewModel: HistoryViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = historyViewModel {
                    content(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("History")
        }
        .onAppear {
            let uid = authViewModel.currentUserId
            guard !uid.isEmpty else { return }
            if historyViewModel?.userId != uid {
                historyViewModel = HistoryViewModel(dataStore: dataStore, userId: uid)
            }
            historyViewModel?.loadSessions()
        }
    }

    @ViewBuilder
    private func content(vm: HistoryViewModel) -> some View {
        if vm.sessions.isEmpty && !vm.isLoading {
            ContentUnavailableView(
                "No Workouts Yet",
                systemImage: "clock",
                description: Text("Your completed workouts will appear here.")
            )
        } else {
            List {
                ForEach(vm.sessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.planName).font(.headline)
                            HStack(spacing: 4) {
                                Text(session.startedAt.formatted(date: .abbreviated, time: .omitted))
                                Text("·")
                                Text(session.formattedDuration)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { vm.deleteSession(vm.sessions[index]) }
                }
            }
        }
    }
}
