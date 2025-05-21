import SwiftUI

struct UserRatingSheetView: View {
    let profile: UserProfile
    @EnvironmentObject var userManager: UserManager

    // Get rated movie data from global movie list
    var ratedMovies: [(movie: Movie, score: Int)] {
        profile.ratedMovies.compactMap { (title, score) in
            if let movie = GlobalMovies.shared.movies.first(where: { $0.title == title }) {
                return (movie, score)
            }
            return nil
        }
    }

    // 2-column layout
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ratedMovies, id: \.movie.id) { item in
                        VStack(spacing: 8) {
                            if let imageName = item.movie.posterImageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .cornerRadius(8)
                            } else {
                                Color.gray.frame(height: 120).cornerRadius(8)
                            }

                            Text("⭐ \(item.score)/10")
                                .font(.caption)
                                .bold()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Rating Record")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
