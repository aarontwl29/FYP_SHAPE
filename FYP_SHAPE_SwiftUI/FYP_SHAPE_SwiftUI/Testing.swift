import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel = MovieViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.movies) { movie in
                HStack(alignment: .top, spacing: 12) {
                    
                    Image(movie.posterImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 100)
                        .clipped()
                        .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title)
                            .font(.headline)

                        Text("\(movie.year) • \(movie.length ?? 0) mins")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(movie.genres.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Movies")
        }
        .onAppear {
            viewModel.fetchMovies()
        }
    }
}
