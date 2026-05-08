# SimplestWorkout

A minimal iOS fitness app for creating workout plans, logging sessions, and tracking progress.

## Features

- **Workout Plans** — Create custom plans with exercises, target sets, and reps. Optionally assign plans to specific days of the week, or use the built-in generator to create PPL, Upper/Lower, or Full Body splits in seconds.
- **Active Sessions** — Log sets, reps, and weight in real time during a workout. Fields pre-fill from your last completed session so you always know what to beat.
- **Session History** — Review past workouts with full exercise details, session duration, and how you felt.
- **Weight Tracker** — Log body weight over time with a trend chart and delta stats.
- **Dashboard** — See this week's sessions, all-time count, weekly streak, and recent activity at a glance.
- **Exercise Library** — Browse and search exercises via ExerciseDB (RapidAPI), with animated GIFs demonstrating proper form.

## Tech Stack

| | |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Storage | SwiftData |
| Auth | Firebase Authentication |
| Charts | Swift Charts |
| Exercise API | ExerciseDB (RapidAPI) |
| Min iOS | 18.1 |

## Architecture

MVVM with the `@Observable` macro and Swift Concurrency (`async/await`).

```
Models (SwiftData)   →   Services   →   ViewModels (@Observable)   →   Views (SwiftUI)
```

- **Models** — `WorkoutPlan`, `Exercise`, `WorkoutSession`, `LoggedExercise`, `WeightLog`
- **Services** — `AuthService` (Firebase), `DataStore` (SwiftData), `ExerciseDBService` (REST)
- **ViewModels** — one per feature area: Auth, Plans, Session, History, Dashboard, Weight

All data is stored locally on device (offline-first). Firebase is used only for authentication.

## Getting Started

### Prerequisites

- Xcode 16+
- iOS 18.1+ device or simulator
- A [Firebase](https://firebase.google.com) project with Email/Password auth enabled
- A [RapidAPI](https://rapidapi.com) key with access to the ExerciseDB API (optional — only needed for the exercise browser)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/SimplyWorkout.git
   cd SimplyWorkout
   ```

2. Add your `GoogleService-Info.plist` from your Firebase project into the `SimplyWorkout/` directory.

3. Open `SimplyWorkout.xcodeproj` in Xcode.

4. Build and run on a simulator or device (⌘R).

5. To use the exercise browser, open the **Profile** tab in the app and enter your RapidAPI key.

## Project Structure

```
SimplyWorkout/
├── App/
│   └── SimplyWorkoutApp.swift       # Entry point, Firebase + SwiftData setup
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── WorkoutSession.swift
│   ├── LoggedExercise.swift
│   ├── WeightLog.swift
│   └── Enums/                       # WorkoutFeeling, DayOfWeek
├── Services/
│   ├── AuthService.swift
│   ├── DataStore.swift
│   └── ExerciseDBService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── PlansViewModel.swift
│   ├── SessionViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── DashboardViewModel.swift
│   └── WeightViewModel.swift
└── Views/
    ├── Auth/
    ├── Dashboard/
    ├── Plans/
    ├── Session/
    ├── History/
    ├── Weight/
    └── Profile/
```

## License

MIT
