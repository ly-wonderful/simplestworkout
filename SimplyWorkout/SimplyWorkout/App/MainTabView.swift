import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            PlansListView()
                .tabItem { Label("Plans", systemImage: "list.bullet.clipboard") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
            WeightTrackerView()
                .tabItem { Label("Weight", systemImage: "scalemass.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
