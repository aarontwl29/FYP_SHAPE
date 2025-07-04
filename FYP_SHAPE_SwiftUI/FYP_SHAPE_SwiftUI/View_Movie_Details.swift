import SwiftUI

struct MovieDetailView: View {
    @EnvironmentObject var userManager: UserManager
    
    @StateObject private var viewModel = MovieViewModel()
    let movie: Movie
    @State private var relatedMovies: [Movie] = []
    
    @State private var showFullDescription = false
    @State private var showReviews = false
    
    @State private var showSearchSheet = false
    @State private var filteredMovies: [Movie] = []
    @State private var searchType: SearchType = .keywords
    @State private var queryText: String = ""
    
    @State private var showRelatedSheet = false
    @State private var relatedMovie: Movie? = nil
    @State private var recommendedMovies: [Movie] = []
    
    
    @State private var isInWatchlist = false
    @State private var showRatingSheet = false
    @State private var currentUserRating: Int? = nil

    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: Poster + Right Panel
                HStack(alignment: .top, spacing: 16) {
                    if let imageName = movie.posterImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 180)
                            .clipped()
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // Title
                        Text(movie.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        
                        
                        
                        
                        // Directed by
                        if !movie.director.isEmpty {
                            Text("Directed by")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(movie.director.components(separatedBy: ","), id: \.self) { name in
                                    HStack(spacing: 10) {
                                        Image(uiImage: UIImage(named: name.trimmingCharacters(in: .whitespaces)) ?? UIImage(named: "user_icon")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        
                                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                                        Button(action: {
                                            searchType = .director
                                            queryText = trimmed
                                            filteredMovies = viewModel.allMovies.filter {
                                                $0.director.localizedCaseInsensitiveContains(trimmed)
                                            }
                                            showSearchSheet = true
                                        }) {
                                            Text(name.trimmingCharacters(in: .whitespaces))
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        Spacer()
                        
                        // Year + Length
                        HStack(spacing: 12) {
                            Text("\(movie.year)")
                            if let length = movie.length {
                                Text("\(length) mins")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .frame(height: 180, alignment: .top)
                }
                
                // MARK: Genres (horizontal scroll)
                if !movie.genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(movie.genres, id: \.self) { genre in
                                Button(action: {
                                    searchType = .keywords
                                    queryText = genre
                                    filteredMovies = viewModel.allMovies.filter {
                                        $0.genres.contains { $0.localizedCaseInsensitiveContains(genre) }
                                    }
                                    showSearchSheet = true
                                }) {
                                    Text(genre)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                // MARK: Description with Show More (right aligned)
                VStack(alignment: .leading, spacing: 6) {
                    Text(showFullDescription ? movie.description : String(movie.description.prefix(100)) + "...")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showFullDescription.toggle()
                            }
                        }) {
                            Text(showFullDescription ? "Show Less" : "Show More")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                
                
                
                
                // Ratings Row
                HStack(alignment: .top, spacing: 30) {
                    
                    // IMDb Rating
                    VStack(alignment: .center, spacing: 4) {
                        Text("IMDb")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: 50)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(movie.ratings.imdb.score, specifier: "%.1f")/10")
                                .bold()
                        }
                        if let votes = movie.ratings.imdb.votes {
                            Text(votes >= 1000 ? "\(votes / 1000)K+" : "\(votes)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // App Unified Rating
                    VStack(alignment: .center, spacing: 4) {
                        Text("APP")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: 50)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(movie.unifiedRating, specifier: "%.1f")/10")
                                .bold()
                        }
                        Text("")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Rotten Tomatoes (Tomatometer)
                    VStack(alignment: .center, spacing: 4) {
                        Text("Tomato")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: 60)
                        Text("\(movie.ratings.rt_tomatometer.score)%")
                            .bold()
                            .foregroundColor(.red)
                        if let count = movie.ratings.rt_tomatometer.votes {
                            Text(count >= 1000 ? "\(count / 1000)K+ Reviews" : "\(count) Reviews")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Rotten Tomatoes (Popcorn)
                    VStack(alignment: .center, spacing: 4) {
                        Text("Popcorn")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: 60)
                        Text("\(movie.ratings.rt_popcorn.score)%")
                            .bold()
                            .foregroundColor(.orange)
                        if let count = movie.ratings.rt_popcorn.votes {
                            Text(count >= 1000 ? "\(count / 1000)K+ Votes" : "\(count) Votes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 5)
                
                
                
                
                HStack {
                    // 🔴 Left: View Reviews
                    Button(action: {
                        showReviews = true
                    }) {
                        Label("Reviews", systemImage: "text.bubble")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }

                    Spacer()

                    // ⭐ Center: Rate
                    Button(action: {
                        showRatingSheet = true
                    }) {
                        Label {
                            Text(currentUserRating != nil ? "Rated: \(currentUserRating!)/10" : "Rate")
                        } icon: {
                            Image(systemName: currentUserRating != nil ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                    }

                    Spacer()

                    // 📌 Right: Watchlist
                    Button(action: {
                        isInWatchlist.toggle()
                        if isInWatchlist {
                            userManager.user.savedTitles.append(movie.title)
                        } else {
                            userManager.user.savedTitles.removeAll { $0 == movie.title }
                        }
                    }) {
                        Label(isInWatchlist ? "Saved" : "Watchlist", systemImage: isInWatchlist ? "bookmark.fill" : "bookmark")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 8)

                
                
                
                
                
                
                
                Text("Stars")
                    .font(.headline)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(movie.stars, id: \.self) { star in
                            let trimmed = star.trimmingCharacters(in: .whitespaces)
                            Button(action: {
                                searchType = .stars
                                queryText = trimmed
                                filteredMovies = viewModel.allMovies.filter {
                                    $0.stars.contains { $0.localizedCaseInsensitiveContains(trimmed) }
                                }
                                showSearchSheet = true
                                print(queryText)
                            }) {
                                VStack(spacing: 6) {
                                    // Fixed region for image
                                    ZStack {
                                        Color.clear.frame(width: 60, height: 60) // Fixed image space
                                        Image(uiImage: UIImage(named: star) ?? UIImage(named: "user_icon")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    }
                                    
                                    // Fixed region for text
                                    Text(star)
                                        .font(.system(size: 13))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                        .frame(width: 70, height: 34) // Fixed size for name label
                                }
                                .frame(width: 80) // Total space per item
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                
                
                
                
                
                
                
                // MARK: - Related Films
                Text("Related Films")
                    .font(.headline)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(relatedMovies, id: \.id) { movie in
                            Button(action: {
                                relatedMovie = movie
                                DispatchQueue.main.async {
                                    showRelatedSheet = true
                                }
                            }) {
                                VStack {
                                    if let poster = movie.posterImageName {
                                        Image(poster)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 150)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                    Text(movie.title)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .frame(width: 100)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                
                // MARK: - You May Be Interested
                Text("You May Be Interested")
                    .font(.headline)
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recommendedMovies, id: \.id) { movie in
                            Button(action: {
                                relatedMovie = movie
                                DispatchQueue.main.async {
                                    showRelatedSheet = true
                                }
                            }) {
                                VStack {
                                    if let poster = movie.posterImageName {
                                        Image(poster)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 150)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                    Text(movie.title)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .frame(width: 100)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                
                
                
                
                
                
                
            }
            .padding()
        }
        .onAppear {
            if let rating = userManager.user.ratedMovies[movie.title] {
                currentUserRating = rating
            }

            
            isInWatchlist = userManager.user.savedTitles.contains(movie.title)
            
            viewModel.fetchMovies()
            
            // 👇 Force global movie list to allow matching in fetchRecommendations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                GlobalMovies.shared.movies = viewModel.allMovies
                
                viewModel.fetchRelatedMovies(for: movie.title) { result in
                    self.relatedMovies = result
                }
                
                if !userManager.user.recentClickedTitles.contains(movie.title) {
                    userManager.user.recentClickedTitles.append(movie.title)
                }
                
                userManager.fetchRecommendations(for: movie.title) { result in
                    print("🟢 Recommended UI update: \(result.map(\.title))")
                    self.recommendedMovies = result
                }
            }
        }
        
        
        .sheet(isPresented: $showReviews) {
            if let poster = movie.poster_path {
                MovieReviewSheetView(posterPath: poster)
            }
        }
        .sheet(isPresented: $showRelatedSheet) {
            if let movie = relatedMovie {
                MovieDetailView(movie: movie)
            }
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchResultView(
                movies: filteredMovies,
                queryText: queryText,
                selectedType: searchType,
                selectedGenre: searchType == .keywords ? queryText : nil,
                sortByRating: false,
                sortByYear: false
            )
        }
        .sheet(isPresented: $showRatingSheet) {
            RatingInputView(movieTitle: movie.title, isPresented: $showRatingSheet)
                .environmentObject(userManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didRateMovie)) { note in
            guard let ratedTitle = note.object as? String, ratedTitle == movie.title else { return }
            currentUserRating = userManager.user.ratedMovies[movie.title]
        }
        
    }
}
