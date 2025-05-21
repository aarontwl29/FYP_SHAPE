import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String  // ← this is mapped from "user_id"
    var recentClickedTitles: [String]
    var ratedMovies: [String: Int]
    var savedTitles: [String]
    var preferredGenres: [String]
    var preferredKeywords: [String]
    var lastActive: String?
    var similarUsers: [String]

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case recentClickedTitles = "recent_clicked_titles"
        case ratedMovies = "rated_movies"
        case savedTitles = "saved_titles"
        case preferredGenres = "preferred_genres"
        case preferredKeywords = "preferred_keywords"
        case lastActive = "last_active"
        case similarUsers = "similar_users"
    }
}


class UserManager: ObservableObject {
    @Published var user: UserProfile = UserProfile(
        id: "guest_user",
        recentClickedTitles: [],
        ratedMovies: [:],
        savedTitles: [],
        preferredGenres: [],
        preferredKeywords: [],
        lastActive: ISO8601DateFormatter().string(from: Date()),
        similarUsers: []
    )
    @Published var otherUsers: [UserProfile] = []
    
    func fetchAllUsers() {
        guard let url = URL(string: "http://127.0.0.1:5000/all_users") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("❌ No user data:", error ?? "")
                return
            }
            do {
                let users = try JSONDecoder().decode([UserProfile].self, from: data)
                DispatchQueue.main.async {
                    // Remove self from list
                    self.otherUsers = users.filter { $0.id != self.user.id }
                    print("✅ Loaded users: \(self.otherUsers.map(\.id))")
                }
            } catch {
                print("❌ JSON decoding error:", error)
            }
        }.resume()
    }
    
    
    func fetchRecommendations(for clickedMovie: String, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/next_suggestion") else { return }
        
        let requestBody: [String: Any] = [
            "user": encodeUserDict(),
            "movie_title": clickedMovie
        ]
        
        print("next recommendations")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("❌ No data from /next_suggestion:", error?.localizedDescription ?? "unknown error")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Server response: \(jsonString)")  // ✅ Step 1: Raw response
            }
            
            do {
                let recommendedTitles = try JSONDecoder().decode([String].self, from: data)
                print("✅ Decoded titles:", recommendedTitles)  // ✅ Step 2: Confirm decoded list
                
                let allMovies = GlobalMovies.shared.movies
                let matched = recommendedTitles.compactMap { title in
                    let match = allMovies.first { $0.title == title }
                    if match == nil {
                        print("⚠️ Title not found in local movies:", title)  // ✅ Step 3: Detect mismatches
                    }
                    return match
                }
                
                print("🎯 Matched Movies:", matched.map(\.title))  // ✅ Step 4: See matched results
                
                DispatchQueue.main.async {
                    completion(matched)
                }
                
            } catch {
                print("❌ Title list decode error:", error)
            }
        }.resume()
        
    }
    
    private func encodeUserDict() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(user),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }
    
    /// ✅ Debug summary output: counts of key fields
    func debugSummary() -> String {
        var lines: [String] = []
        
        lines.append("🧠 USER DEBUG SUMMARY")
        lines.append("🆔 ID: \(user.id)")
        lines.append("🖱️  Clicked Titles: \(user.recentClickedTitles.count)")
        
        // ⭐ Detailed Rated Movies Output
        if user.ratedMovies.isEmpty {
            lines.append("⭐ Rated Movies: 0")
        } else {
            let details = user.ratedMovies.map { "\"\($0.key)\": \($0.value)" }
                .joined(separator: ", ")
            lines.append("⭐ Rated Movies: \(user.ratedMovies.count) — [\(details)]")
        }
        
        lines.append("📌 Saved Titles: \(user.savedTitles.count)")
        lines.append("🏷️ Preferred Genres: \(user.preferredGenres.count) — \(summarize(topOf: user.preferredGenres))")
        lines.append("🔤 Preferred Keywords: \(user.preferredKeywords.count) — \(summarize(topOf: user.preferredKeywords))")
        lines.append("👥 Similar Users: \(user.similarUsers.count)")
        lines.append("🕒 Last Active: \(user.lastActive)")
        
        return lines.joined(separator: "\n")
    }
    
    
    /// Helper: summarize top 3 values
    private func summarize(topOf list: [String]) -> String {
        let counted = Dictionary(grouping: list, by: { $0 }).mapValues { $0.count }
        let top = counted.sorted { $0.value > $1.value }.prefix(3)
        return top.map { "\($0.key)(\($0.value))" }.joined(separator: ", ")
    }
}
