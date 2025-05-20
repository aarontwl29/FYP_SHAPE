import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MovieViewModel()
    @State private var selectedMovie: Movie? = nil
    @State private var showDetail = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Section 1: Top 10 Popular Films
                Section(header: Text("🔥 Top 10 Popular Films")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)) {

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(topRatedMovies.prefix(10)) { movie in
                            MoviePosterItem(movie: movie) {
                                selectedMovie = movie
                                showDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Section 2: You May Be Interested
                Section(header: Text("✨ You May Be Interested")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)) {

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.allMovies.prefix(10)) { movie in
                            MoviePosterItem(movie: movie) {
                                selectedMovie = movie
                                showDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .onAppear {
            viewModel.fetchMovies()
        }
        .sheet(isPresented: $showDetail) {
            if let movie = selectedMovie {
                MovieDetailView(movie: movie)
            }
        }
    }

    // MARK: - Computed

    var topRatedMovies: [Movie] {
        viewModel.allMovies.sorted { $0.unifiedRating > $1.unifiedRating }
    }
}


struct MoviePosterItem: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            if let imageName = movie.posterImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .cornerRadius(8)
            } else {
                Color.gray
                    .frame(height: 140)
                    .cornerRadius(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}



#Preview {
    HomeView()
}
