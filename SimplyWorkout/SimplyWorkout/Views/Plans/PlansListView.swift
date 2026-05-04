import SwiftUI

struct PlansListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataStore.self) private var dataStore
    @State private var plansViewModel: PlansViewModel?
    @State private var showEditor = false
    @State private var showGenerator = false

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
                    HStack {
                        Button { showGenerator = true } label: {
                            Image(systemName: "wand.and.stars")
                        }
                        Button { showEditor = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                if let vm = plansViewModel {
                    PlanEditorView(mode: .create, plansViewModel: vm)
                }
            }
            .sheet(isPresented: $showGenerator) {
                if let vm = plansViewModel {
                    WorkoutGeneratorView(plansViewModel: vm)
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
            let unscheduled = vm.plans.filter { $0.dayOfWeek == nil }
            let hasScheduled = vm.plans.contains { $0.dayOfWeek != nil }
            List {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    let dayPlans = vm.plans.filter { $0.dayOfWeek == day }
                    if !dayPlans.isEmpty {
                        Section(day.label) {
                            planRows(dayPlans, vm: vm)
                        }
                    }
                }
                if !unscheduled.isEmpty {
                    Section(hasScheduled ? "Unscheduled" : "") {
                        planRows(unscheduled, vm: vm)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func planRows(_ plans: [WorkoutPlan], vm: PlansViewModel) -> some View {
        ForEach(plans) { plan in
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
            for index in indexSet { vm.deletePlan(plans[index]) }
        }
    }
}
