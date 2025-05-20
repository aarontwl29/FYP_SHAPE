import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String  // user_id

    var recentClickedTitles: [String]          // Recent movie titles clicked
    var ratedMovies: [String: Int]             // [movieTitle: rating]
    var savedTitles: [String]                  // Watchlist
    var preferredGenres: [String]              // From recent activity
    var preferredKeywords: [String]            // From emotion/keyword extraction
    var lastActive: String
    var similarUsers: [String]
}
