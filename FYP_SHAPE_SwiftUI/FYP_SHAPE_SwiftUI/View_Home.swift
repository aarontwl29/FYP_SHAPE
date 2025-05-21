import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    
    @State private var recommendedMovies: [Movie] = []
    
    
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
                
                //  You May Be Interested
                Section {
                    HStack {
                        Text("✨ You May Be Interested")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: refreshRecommendations) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(recommendedMovies.prefix(10)) { movie in
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
            refreshRecommendations()
        }
        .sheet(isPresented: $showDetail) {
            if let movie = selectedMovie {
                MovieDetailView(movie: movie)
                    .environmentObject(userManager)
            }
        }
    }
    
    // MARK: - Computed
    
    var topRatedMovies: [Movie] {
        let sorted = viewModel.allMovies.sorted { $0.unifiedRating > $1.unifiedRating }
        print("🔥 Sorted Top:", sorted.prefix(5).map { "\($0.title): \($0.unifiedRating)" })
        return sorted
    }
    
    func refreshRecommendations() {
        print("🔄 Refreshing top 10 recommendations from full user profile")
        
        viewModel.fetchProfileRecommendations(for: userManager.user) { movies in
            self.recommendedMovies = movies
        }
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
