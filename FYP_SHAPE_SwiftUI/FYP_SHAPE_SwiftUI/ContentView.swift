import SwiftUI

struct Movie: Identifiable, Codable {
    let id = UUID()
    let title: String
    let year: Int
}

struct ContentView: View {
    @State private var movies: [Movie] = []
    @State private var genre: String = "Thriller"

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter genre", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Search by Genre") {
                    fetchMoviesByGenre(genre)
                }

                List(movies) { movie in
                    Text("\(movie.title) (\(movie.year))")
                }
            }
            .navigationTitle("Movie Finder")
        }
    }

    func fetchMoviesByGenre(_ genre: String) {
        guard let url = URL(string: "http://127.0.0.1:5000/search/genre?genre=\(genre)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode([Movie].self, from: data) {
                DispatchQueue.main.async {
                    self.movies = decoded
                }
            }
        }.resume()
    }
}
