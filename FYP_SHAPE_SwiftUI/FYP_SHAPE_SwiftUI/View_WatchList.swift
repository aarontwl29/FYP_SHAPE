import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var userManager: UserManager
    var profile: UserProfile?
    
    var effectiveUser: UserProfile {
        profile ?? userManager.user  // use correct name
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()),
                   GridItem(.flexible()), GridItem(.flexible())]
    
    // Use passed-in profile or fallback to current user
    var currentProfile: UserProfile {
        profile ?? userManager.user
    }
    
    // Filter GlobalMovies by saved titles
    var savedMovies: [Movie] {
        GlobalMovies.shared.movies.filter {
            currentProfile.savedTitles.contains($0.title)
        }
    }
    
    var body: some View {
        ScrollView {
            if savedMovies.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    Text("No saved movies.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(savedMovies, id: \.id) { movie in
                        VStack {
                            if let poster = movie.posterImageName {
                                Image(poster)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 140)
                                    .cornerRadius(8)
                            }
                            Text(movie.title)
                                .font(.caption2)
                                .lineLimit(1)
                                .frame(width: 80)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
