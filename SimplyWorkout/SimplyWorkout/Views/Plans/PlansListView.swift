import SwiftUI

struct PlansListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var plansViewModel: PlansViewModel?
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = plansViewModel {
                    content(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Plans")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showEditor = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                if let vm = plansViewModel {
                    PlanEditorView(mode: .create, plansViewModel: vm)
                }
            }
        }
        .onAppear {
            let uid = authViewModel.currentUserId
            guard !uid.isEmpty else { return }
            if plansViewModel?.userId != uid {
                plansViewModel = PlansViewModel(dataStore: dataStore, userId: uid)
            }
            plansViewModel?.loadPlans()
        }
    }

    @ViewBuilder
    private func content(vm: PlansViewModel) -> some View {
        if vm.plans.isEmpty && !vm.isLoading {
            ContentUnavailableView(
                "No Plans Yet",
                systemImage: "list.bullet.clipboard",
                description: Text("Tap + to create your first workout plan.")
            )
        } else {
            List {
                ForEach(vm.plans) { plan in
                    NavigationLink {
                        PlanDetailView(plan: plan, plansViewModel: vm)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name).font(.headline)
                            Text("\(plan.exercises.count) exercise\(plan.exercises.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { vm.deletePlan(vm.plans[index]) }
                }
            }
        }
    }
}
