import SwiftUI

struct StrategyView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fat loss comes down to creating a calorie deficit, but your training should preserve (and even build) muscle while maximizing calorie burn. The best approach combines strength training as the foundation with cardio as a tool — not the other way around.")
                        .font(.body)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Core Strategy")
            }

            Section("Weekly Structure") {
                scheduleRow(day: "Monday",    focus: "Strength – Lower Body (squat pattern)")
                scheduleRow(day: "Tuesday",   focus: "Strength – Upper Body (push / pull)")
                scheduleRow(day: "Wednesday", focus: "Cardio / Active Recovery")
                scheduleRow(day: "Thursday",  focus: "Strength – Full Body or weak points")
                scheduleRow(day: "Friday",    focus: "HIIT or Circuit Training")
                scheduleRow(day: "Sat / Sun", focus: "Rest or light walk")
                Text("Drop Wednesday to run a 4-day version with full rest mid-week.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Section("Strength Sessions (Mon · Tue · Thu)") {
                bulletPoint("Warm-up: 5–10 min light cardio + dynamic stretching")
                bulletPoint("Main lifts: 3–4 exercises, 3–4 sets × 8–12 reps, ~60 sec rest")
                bulletPoint("Finisher: 10 min of supersets or bodyweight circuit to spike heart rate")
                Text("Good staples: squats, Romanian deadlifts, bench press, rows, overhead press, pull-ups.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Section("Cardio Sessions (Wed · Fri)") {
                Text("HIIT is more time-efficient than steady-state for fat loss.")
                    .font(.subheadline)
                    .padding(.bottom, 2)
                bulletPoint("20–30 min total")
                bulletPoint("30–40 sec hard effort (sprint, bike, rower, jump rope)")
                bulletPoint("60–90 sec easy recovery")
                bulletPoint("Repeat 8–12 rounds")
                Text("Save steady-state cardio (30–45 min walk or jog) for active recovery days — it burns calories without taxing recovery.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Section("Key Principles") {
                principleRow(
                    icon: "arrow.up.right",
                    title: "Progressive Overload",
                    body: "Gradually increase weight or reps over time. This is what preserves muscle while you're in a deficit."
                )
                principleRow(
                    icon: "fork.knife",
                    title: "Protein Intake",
                    body: "Aim for ~0.7–1 g of protein per pound of bodyweight daily. The single biggest dietary lever for body recomposition."
                )
                principleRow(
                    icon: "moon.zzz",
                    title: "Sleep",
                    body: "Non-negotiable. Poor sleep spikes cortisol and hunger hormones, which actively work against fat loss."
                )
                principleRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Something",
                    body: "Weights lifted, weekly photos, or measurements. The scale alone is misleading week-to-week."
                )
            }

            Section("What to Avoid") {
                bulletPoint("Don't train 6–7 days thinking more is better — recovery is when your body actually changes.")
                bulletPoint("Don't slash calories so hard that your strength drops significantly; that's a sign you're losing muscle, not just fat.")
            }
        }
        .navigationTitle("Training Strategy")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func scheduleRow(day: String, focus: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(day)
                .font(.subheadline.bold())
                .frame(width: 90, alignment: .leading)
            Text(focus)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•").foregroundStyle(.secondary)
            Text(text).font(.subheadline)
        }
    }

    @ViewBuilder
    private func principleRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(body).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
