import Foundation

struct Movie: Identifiable, Decodable {
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

    var posterImageName: String {
        guard let path = poster_path else { return "placeholder" }
        return path.components(separatedBy: "/").last?.replacingOccurrences(of: ".jpg", with: "") ?? "placeholder"
    }
}


struct Ratings: Decodable {
    let imdb: IMDBRating
    let rt_popcorn: RTRating
    let rt_tomatometer: RTTomatometer
}

struct IMDBRating: Decodable {
    let score: Double
    let votes: Int?
}

struct RTRating: Decodable {
    let score: Int
    let votes: Int?
}

struct RTTomatometer: Decodable {
    let reviews: Int
    let score: Int
}

struct Hashtags: Decodable {
    let top_emotions: [String]
    let top_keywords: [String]
}














import Foundation

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []

    func fetchMovies() {
        guard let url = URL(string: "http://127.0.0.1:5000/movies") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedMovies = try JSONDecoder().decode([Movie].self, from: data)
                    DispatchQueue.main.async {
                        self.movies = decodedMovies
                    }
                } catch {
                    print("Decoding error:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
}
