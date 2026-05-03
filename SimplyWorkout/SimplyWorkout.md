# SimplyWorkout — iOS App Specification

A minimal iOS fitness app focused on three things: getting users in the door, helping them plan workouts, and letting them log what they did. No bloat.

---

## 1. Overview

**Platform:** iOS 16+
**Language / Framework:** Swift 5.9, SwiftUI
**Persistence:** SwiftData (or Core Data fallback) for local storage; Firebase Auth for login
**Architecture:** MVVM
**Distribution:** App Store

### Core Value Proposition
A workout app that does exactly three things well — authenticate the user, let them build a plan, and let them log activity against that plan. No social feed. No coaching. No subscription paywall in v1.

---

## 2. Feature Scope (v1)

### 2.1 Authentication
- Email + password sign up
- Email + password sign in
- "Forgot password" flow (email reset link)
- Sign out
- Persistent session (user stays logged in across app launches)

### 2.2 Workout Plan Creation
- Create a named plan (e.g., "Push Day", "Leg Day")
- Add exercises to a plan (name, target sets, target reps, optional notes)
- Edit or delete exercises within a plan
- Edit or delete an entire plan
- View list of all plans on a home screen

### 2.3 Activity Logging
- Start a workout session from a plan
- For each exercise, log actual sets, reps, and weight used
- Mark a session complete with a timestamp
- View history of past sessions
- Tap any past session to see what was done

---

## 3. Screens

| # | Screen | Purpose |
|---|--------|---------|
| 1 | Splash / Auth Gate | Routes to Sign In or Home based on auth state |
| 2 | Sign In | Email + password fields, link to Sign Up |
| 3 | Sign Up | Email, password, confirm password |
| 4 | Home (Plans List) | Lists all user's workout plans, "+" to create new |
| 5 | Plan Detail | Shows exercises in a plan, "Start Workout" button, edit/delete |
| 6 | Plan Editor | Form to create/edit a plan and its exercises |
| 7 | Active Session | Logs sets/reps/weight per exercise during a workout |
| 8 | History | Chronological list of completed sessions |
| 9 | Session Detail | Read-only view of a past session |
| 10 | Profile / Settings | Email, sign out button |

---

## 4. Data Model

### User
- `id: String`
- `email: String`
- `createdAt: Date`

### WorkoutPlan
- `id: UUID`
- `userId: String`
- `name: String`
- `exercises: [Exercise]`
- `createdAt: Date`

### Exercise
- `id: UUID`
- `name: String`
- `targetSets: Int`
- `targetReps: Int`
- `notes: String?`

### WorkoutSession
- `id: UUID`
- `userId: String`
- `planId: UUID`
- `planName: String` *(snapshot, in case plan is later deleted)*
- `startedAt: Date`
- `completedAt: Date?`
- `loggedExercises: [LoggedExercise]`

### LoggedExercise
- `id: UUID`
- `exerciseName: String`
- `sets: [LoggedSet]`

### LoggedSet
- `reps: Int`
- `weight: Double` *(in lbs or kg, user preference)*

---

## 5. Navigation Flow

```
Launch
  └─ Auth Gate
       ├─ (signed out) → Sign In ⇄ Sign Up
       └─ (signed in) → Tab Bar
                         ├─ Home (Plans)
                         │    ├─ Plan Detail
                         │    │    ├─ Plan Editor
                         │    │    └─ Active Session → (saves to History)
                         │    └─ Plan Editor (new)
                         ├─ History
                         │    └─ Session Detail
                         └─ Profile
```

---

## 6. Tech Decisions

- **SwiftUI over UIKit** — faster to build, plenty for this scope.
- **SwiftData over Core Data** — modern, less boilerplate; requires iOS 17+. If iOS 16 support is needed, fall back to Core Data.
- **Firebase Auth** — easiest path to a working email/password flow. If avoiding Firebase, use Sign in with Apple + a custom backend, or skip auth in v1 and store everything locally per-device.
- **No backend sync in v1** — workout data lives on device. Add iCloud sync in v2 if needed.

---

## 7. Project Structure

```
SimplyWorkout/
├── App/
│   └── SimplyWorkoutApp.swift
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── WorkoutSession.swift
│   └── LoggedSet.swift
├── Views/
│   ├── Auth/
│   │   ├── SignInView.swift
│   │   └── SignUpView.swift
│   ├── Plans/
│   │   ├── PlansListView.swift
│   │   ├── PlanDetailView.swift
│   │   └── PlanEditorView.swift
│   ├── Session/
│   │   └── ActiveSessionView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── SessionDetailView.swift
│   └── Profile/
│       └── ProfileView.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── PlansViewModel.swift
│   └── SessionViewModel.swift
└── Services/
    ├── AuthService.swift
    └── DataStore.swift
```

---

## 8. Build Order (Suggested)

1. Project setup, Firebase install, basic SwiftUI shell
2. Auth screens + AuthService — get sign in/up/out working end-to-end
3. Data models + DataStore (SwiftData)
4. Plans list + Plan editor — full CRUD on plans
5. Active session screen — logging flow
6. History + Session detail
7. Profile screen + sign out
8. Polish: empty states, loading indicators, error handling
9. App icon, launch screen, App Store screenshots
10. TestFlight build → submit

---

## 9. Out of Scope (for v1)

These get cut to keep v1 simple and shippable:

- Social features, sharing, friends
- Progress charts and analytics
- Exercise library with demonstrations
- Rest timers, audio cues
- Apple Health / HealthKit integration
- Apple Watch companion app
- Workout templates from a catalog
- Subscription / paywall
- Multi-device sync

These are all reasonable v2 candidates.

---

## 10. Open Questions

- Units: lbs only, kg only, or user-toggleable?
- Should plans be reorderable? (drag to reorder vs. fixed order)
- On session completion, should it offer to immediately start a new one?
- Minimum iOS version — 16 or 17?
