import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlansListView()
                .tabItem { Label("Plans", systemImage: "list.clipboard") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
