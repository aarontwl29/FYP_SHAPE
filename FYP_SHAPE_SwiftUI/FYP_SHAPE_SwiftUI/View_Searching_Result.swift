import SwiftUI

struct SearchResultView: View {
    let movies: [Movie]
    let queryText: String
    let selectedType: SearchType
    let selectedGenre: String?
    let sortByRating: Bool
    let sortByYear: Bool

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    @State private var selectedMovie: Movie? = nil
    @State private var showDetail = false
  

    var headerText: some View {
        VStack(alignment: .leading, spacing: 8) {
      

            if let genre = selectedGenre {
                Text("Genres: \(genre)")
                    .font(.title3)
                    .bold()
            } else {
                switch selectedType {
                case .keywords:
                    Text("Keywords: \(queryText)")
                        .font(.title3)
                        .bold()
                case .director, .stars:
                    HStack(alignment: .top, spacing: 12) {
                        Image(imageName(from: queryText))
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(selectedType.rawValue): \(queryText)")
                                .font(.headline)
                            Text("Famous for impactful storytelling and cinematic style.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            if sortByRating || sortByYear {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                    Text("Order by: \(sortText)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }

    var sortText: String {
        var parts: [String] = []
        if sortByYear { parts.append("Release Year") }
        if sortByRating { parts.append("Rating") }
        return parts.joined(separator: ", ")
    }

    func imageName(from name: String) -> String {
        let formatted = name.lowercased().replacingOccurrences(of: " ", with: "_")
        return UIImage(named: formatted) != nil ? formatted : "user_icon"
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    headerText
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(movies.prefix(40)) { movie in
                            MoviePosterItem(movie: movie) {
                                selectedMovie = movie
                                showDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
 
        .sheet(isPresented: $showDetail) {
            if let movie = selectedMovie {
                MovieDetailView(movie: movie)
            }
        }
    }
}
