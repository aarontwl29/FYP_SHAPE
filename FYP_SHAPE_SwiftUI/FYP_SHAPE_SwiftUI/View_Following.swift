import SwiftUI

struct FollowingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedUser: UserProfile? = nil
    @State private var showWatchlist = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("👥 Explore Users")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                ForEach(userManager.otherUsers, id: \.id) { other in
                    HStack(alignment: .top, spacing: 12) {
                        Image("user_icon\(other.id)")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(other.id)
                                .font(.headline)

                            Text("⭐ Rated: \(other.ratedMovies.count), 📌 Saved: \(other.savedTitles.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("🏷️ Genres: \(other.preferredGenres.prefix(3).joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundColor(.gray)

                            Text("🔤 Keywords: \(other.preferredKeywords.prefix(3).joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                Button(action: {
                                    toggleFollow(userId: other.id)
                                }) {
                                    Label(
                                        isFollowing(userId: other.id) ? "Following" : "Follow",
                                        systemImage: isFollowing(userId: other.id) ? "person.fill.checkmark" : "person.badge.plus"
                                    )
                                    .font(.caption2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(isFollowing(userId: other.id) ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                }

                                Button(action: {
                                    selectedUser = other
                                    showWatchlist = true
                                }) {
                                    Label("View List", systemImage: "eye")
                                        .font(.caption2)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .padding(.top)
        }
        .sheet(item: $selectedUser) { profile in
            WatchlistView(profile: profile)
                .environmentObject(userManager)
        }
    }

    private func isFollowing(userId: String) -> Bool {
        userManager.user.similarUsers.contains(userId)
    }

    private func toggleFollow(userId: String) {
        if let index = userManager.user.similarUsers.firstIndex(of: userId) {
            userManager.user.similarUsers.remove(at: index)
            print("❌ Unfollowed: \(userId)")
        } else {
            userManager.user.similarUsers.append(userId)
            print("✅ Followed: \(userId)")
        }
    }
}


