import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("weightUnit") private var weightUnit = "lbs"
    @State private var showingImportAlert = false
    @State private var didImport = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("lbs").tag("lbs")
                        Text("kg").tag("kg")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Data") {
                    Button("Import Sample PPL Program") {
                        showingImportAlert = true
                    }
                    .disabled(didImport)
                }

                Section("App") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Profile")
            .alert("Import Plan?", isPresented: $showingImportAlert) {
                Button("Import") { importPPL() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will add a 6-day Push/Pull/Legs program.")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func importPPL() {
        let plan = WorkoutPlan(name: "Push / Pull / Legs")

        let daysData: [(Weekday, String, [(String, Int, Int, String)])] = [
            (.monday, "Push – Heavy", [
                ("Bench Press", 3, 6, "Heavy: 5–8 rep range"),
                ("Overhead Press", 3, 8, ""),
                ("Dumbbell Incline Press", 3, 10, ""),
                ("Tricep Pushdowns", 3, 12, ""),
                ("Lateral Raises", 3, 15, ""),
            ]),
            (.tuesday, "Pull – Heavy", [
                ("Deadlifts", 3, 5, "Heavy"),
                ("Lat Pulldowns / Pull-ups", 3, 8, ""),
                ("Seated Cable Rows", 3, 10, ""),
                ("Face Pulls", 3, 15, "Rear delts / postural health"),
                ("Bicep Curls", 3, 12, "Hammer or barbell"),
            ]),
            (.wednesday, "Legs – Heavy", [
                ("Back Squats", 3, 6, "Heavy: 5–8 rep range"),
                ("Leg Press", 3, 10, ""),
                ("Leg Curls", 3, 12, ""),
                ("Calf Raises", 4, 15, ""),
            ]),
            (.thursday, "Pull – Volume", [
                ("Lat Pulldowns / Pull-ups", 3, 10, ""),
                ("Seated Cable Rows", 3, 10, ""),
                ("Face Pulls", 3, 15, "Rear delts / postural health"),
                ("Bicep Curls", 3, 12, "Hammer or barbell"),
            ]),
            (.friday, "Push – Volume", [
                ("Bench Press", 3, 10, "Volume: 10–12 rep range"),
                ("Overhead Press", 3, 10, ""),
                ("Dumbbell Incline Press", 3, 12, ""),
                ("Tricep Pushdowns", 3, 15, ""),
                ("Lateral Raises", 3, 20, ""),
            ]),
            (.saturday, "Legs – Volume", [
                ("Back Squats", 3, 10, "Volume: 10–12 rep range"),
                ("Leg Press", 3, 12, ""),
                ("Leg Curls", 3, 15, ""),
                ("Calf Raises", 4, 20, ""),
            ]),
        ]

        plan.days = daysData.map { weekday, label, exercises in
            let day = DayRoutine(weekday: weekday, label: label)
            day.exercises = exercises.map {
                Exercise(name: $0.0, targetSets: $0.1, targetReps: $0.2, notes: $0.3)
            }
            return day
        }

        modelContext.insert(plan)
        didImport = true
    }
}
