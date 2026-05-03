import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PlansListView()
                .tabItem { Label("Plans", systemImage: "list.bullet.clipboard") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
