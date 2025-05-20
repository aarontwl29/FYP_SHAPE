import Foundation

import Foundation

// MARK: - Movie

struct Movie: Codable, Identifiable {
    let id = UUID()
    let title: String
    let year: Int
    let genres: [String]
    let description: String
    let director: String
    let stars: [String]
    let length: Int?
    let ratings: Ratings
    let hashtags: Hashtags
    let poster_path: String?

    // Convert JSON image path → Asset name
    var posterImageName: String? {
        guard let path = poster_path,
              !path.isEmpty,
              path != "null" else { return nil }

        return (path as NSString).lastPathComponent
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".png", with: "")
    }

    // Unified rating calculation (1–10 scale)
    var unifiedRating: Double {
        let imdbScore = ratings.imdb.score
        let imdbVotes = ratings.imdb.votes ?? 0

        let tomatoScore = Double(ratings.rt_tomatometer.score) / 10.0
        let tomatoReviews = ratings.rt_tomatometer.votes ?? 0

        let popcornScore = Double(ratings.rt_popcorn.score) / 10.0
        let popcornVotes = ratings.rt_popcorn.votes ?? 0

        let totalVotes = Double(imdbVotes + tomatoReviews + popcornVotes)
        guard totalVotes > 0 else { return 0.0 }

        let imdbPart = imdbScore * Double(imdbVotes)
        let tomatoPart = tomatoScore * Double(tomatoReviews)
        let popcornPart = popcornScore * Double(popcornVotes)

        let result = (imdbPart + tomatoPart + popcornPart) / totalVotes
        return result.rounded(toPlaces: 1)
    }
}

// MARK: - Ratings Container

struct Ratings: Codable {
    let imdb: IMDbRating
    let rt_popcorn: RTRating
    let rt_tomatometer: RTRating
}

// MARK: - IMDb Rating

struct IMDbRating: Codable {
    let score: Double
    let votes: Int?
}

// MARK: - Rotten Tomatoes Rating

struct RTRating: Codable {
    let score: Int
    let votes: Int?

    enum CodingKeys: String, CodingKey {
        case score, votes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        score = try container.decode(Int.self, forKey: .score)
        votes = try? container.decodeIfPresent(Int.self, forKey: .votes)
    }
}

// MARK: - Hashtag Struct

struct Hashtags: Codable {
    let top_emotions: [String]
    let top_keywords: [String]
}

// MARK: - Helper for rounding

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}






class GlobalMovies {
    static let shared = GlobalMovies()
    private init() {}
    
    var movies: [Movie] = []
}












import Foundation

class MovieViewModel: ObservableObject {
    @Published var allMovies: [Movie] = []

    func fetchMovies() {
        guard let url = URL(string: "http://127.0.0.1:5000/movies") else { return }

        print("fetchMovies")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let movies = try JSONDecoder().decode([Movie].self, from: data)
                DispatchQueue.main.async {
                    self.allMovies = movies
                    GlobalMovies.shared.movies = movies
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    
    func fetchRelatedMovies(for title: String, completion: @escaping ([Movie]) -> Void) {
            let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "http://127.0.0.1:5000/related_films?title=\(encodedTitle)") else { return }

            print("Fetching related films for: \(title)")

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data else {
                    print("No data for related films")
                    return
                }
                do {
                    let movies = try JSONDecoder().decode([Movie].self, from: data)
                    DispatchQueue.main.async {
                        completion(movies)
                    }
                } catch {
                    print("Related film decoding error:", error)
                }
            }.resume()
        }
}

