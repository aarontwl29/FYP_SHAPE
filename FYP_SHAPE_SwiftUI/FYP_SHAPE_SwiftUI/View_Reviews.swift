import SwiftUI

struct MovieReviewSheetView: View {
    let posterPath: String
    @State private var reviews: [Review] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Reviews...")
                } else {
                    List(reviews) { review in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .center) {
                                Image("user_icon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())

                                Text(review.username)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)

                                Spacer()

                                HStack(spacing: 2) {
                                    ForEach(0..<review.starCount, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                            }

                            Text(review.text)
                                .font(.system(size: 14))
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("User Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchReviews()
            }
        }
    }

    func fetchReviews() {
        guard let urlEncoded = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://127.0.0.1:5000/reviews?poster_path=\(urlEncoded)") else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let root = try JSONDecoder().decode(ReviewResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.reviews = root.reviews.enumerated().map { index, raw in
                            Review(
                                id: UUID(),
                                username: "User\(1000 + index)",
                                starCount: Self.convertToStars(raw.rating),
                                text: raw.review
                            )
                        }
                        isLoading = false
                    }
                } catch {
                    print("❌ Decoding failed:", error)
                }
            } else if let error = error {
                print("❌ Network error:", error)
            }
        }.resume()
    }

    static func convertToStars(_ ratingString: String) -> Int {
        let parts = ratingString.split(separator: "/")
        if parts.count == 2,
           let score = Double(parts[0]),
           let base = Double(parts[1]) {
            return Int((score / base * 10).rounded())
        }
        return 5
    }
}

// MARK: - Models

struct ReviewResponse: Codable {
    let movie_name: String
    let reviews: [RawReview]
}

struct RawReview: Codable {
    let rating: String
    let review: String
}

struct Review: Identifiable {
    let id: UUID
    let username: String
    let starCount: Int
    let text: String
}
