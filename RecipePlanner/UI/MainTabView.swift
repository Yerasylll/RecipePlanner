import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecipeFeedView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.orange)
    }
}
