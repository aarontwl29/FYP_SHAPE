import SwiftUI

enum SearchType: String, CaseIterable, Identifiable {
    case director = "Director"
    case stars = "Stars"
    case keywords = "Keywords"
    var id: String { rawValue }
}

struct SearchView: View {
    

    
    @StateObject private var viewModel = MovieViewModel()
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @State private var selectedType: SearchType = .director
    @State private var selectedGenre: String? = nil
    @State private var sortByRating = false
    @State private var sortByYear = false
    @State private var showResults = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var filteredMovies: [Movie] {
        var movies = viewModel.allMovies

        if let genre = selectedGenre {
            movies = movies.filter { $0.genres.contains { $0.localizedCaseInsensitiveContains(genre) } }
        } else if !searchText.isEmpty {
            switch selectedType {
            case .director:
                movies = movies.filter { $0.director.localizedCaseInsensitiveContains(searchText) }
            case .stars:
                movies = movies.filter { $0.stars.contains { $0.localizedCaseInsensitiveContains(searchText) } }
            case .keywords:
                movies = movies.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.description.localizedCaseInsensitiveContains(searchText)
                    || $0.hashtags.top_emotions.contains { $0.localizedCaseInsensitiveContains(searchText) }
                    || $0.hashtags.top_keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
                }
            }
        }

        if sortByRating {
            movies = movies.sorted { $0.unifiedRating > $1.unifiedRating }
        }
        if sortByYear {
            movies = movies.sorted { $0.year > $1.year }
        }

        return movies
    }

    var topGenres: [(String, Int)] {
        var genreCounts: [String: Int] = [:]
        for movie in viewModel.allMovies {
            for genre in movie.genres {
                genreCounts[genre, default: 0] += 1
            }
        }
        return genreCounts.sorted { $0.value > $1.value }.prefix(10).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 🔍 Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search...", text: $searchText)
                        .focused($isFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // 🧩 Type Selector
                Picker("Search by", selection: $selectedType) {
                    ForEach(SearchType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // 🔘 Buttons: Reset (left, red) + Search (right, blue)
                HStack {
                    Button("Reset") {
                        searchText = ""
                        selectedGenre = nil
                        sortByRating = false
                        sortByYear = false
                        isFocused = false
                    }
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
                    .bold()

                    Spacer()

                    Button(action: {
                        selectedGenre = nil
                        isFocused = false
                        showResults = true
                    }) {
                        Text("Search")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .bold()
                    }
                }
                .padding(.horizontal)

                // 🔥 Top Genres with Count (Fixed Height Buttons)
                Text("Top Genres")
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(topGenres, id: \.0) { genre, count in
                        Button(action: {
                            selectedGenre = genre
                            showResults = true
                        }) {
                            Text("\(genre) (\(count))")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .frame(height: 36)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .bold()
                        }
                    }
                }
                .padding(.horizontal)

                // ⬇️ Sort Toggles
                VStack(spacing: 12) {
                    HStack {
                        Text("Order by Release Year")
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: $sortByYear)
                            .labelsHidden()
                    }

                    HStack {
                        Text("Order by Rating")
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: $sortByRating)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal)

                Spacer()

                // ➡️ Navigation to Result View
                NavigationLink(
                    destination: SearchResultView(
                        movies: filteredMovies,
                        queryText: searchText,
                        selectedType: selectedType,
                        selectedGenre: selectedGenre,
                        sortByRating: sortByRating,
                        sortByYear: sortByYear
                    ),
                    isActive: $showResults
                ) {
                    EmptyView()
                }
                .hidden()

            }
            .navigationTitle("🔍 Search")
        }
        .onAppear {
            viewModel.fetchMovies()
        }
    }
}


