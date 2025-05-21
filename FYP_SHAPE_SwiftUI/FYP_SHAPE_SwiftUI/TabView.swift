import SwiftUI

struct MainTabView: View {
    @StateObject private var userManager = UserManager()

    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            // Discover Tab (was SearchView)
            SearchView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }

            // Watchlist Tab
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "bookmark")
                }

            // Following Tab
            FollowingView()
                .tabItem {
                    Label("Following", systemImage: "person.2.fill")
                }
        }
        .onAppear {
            userManager.fetchAllUsers()
        }
        .environmentObject(userManager)
    }
}

#Preview {
    MainTabView()
}
