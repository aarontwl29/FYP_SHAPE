import SwiftUI

struct FollowingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedUser: UserProfile?
    
    @State private var showRatingSheet = false
    @State private var selectedRatingUser: UserProfile?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("👥 Explore Users")
                    .font(.title2.bold())
                    .padding(.horizontal)

                ForEach(userManager.otherUsers, id: \.id) { other in
                    VStack(spacing: 10) {
                        HStack(alignment: .top, spacing: 12) {
                            // === Icon (2 rows height)
                            Image("user_icon")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .padding(.top, 4)

                            VStack(alignment: .leading, spacing: 4) {
                                // Row 1: Username + Rating Record
                                HStack {
                                    Text(other.id)
                                        .font(.system(size: 16, weight: .semibold))

                                    Spacer()

                                    Button("📈 Rating Record") {
                                        selectedRatingUser = other
                                            showRatingSheet = true
                                    }
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(6)
                                }

                                HStack {
                                    // Row 2: Rated / Saved
                                    Text("⭐ Rated: \(other.ratedMovies.count)   📌 Saved: \(other.savedTitles.count)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button("📋 View List") {
                                        selectedUser = other
                                    }
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                                }
                            }
                        }

                        // Row 3: Genres + View List
                        HStack(alignment: .center) {
                            Text("🎬 Genres: \(other.preferredGenres.prefix(3).joined(separator: ", "))")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            Spacer()

                            
                        }

                        // Row 4: Keywords + Follow
                        HStack(alignment: .center) {
                            Text("🔑 Keywords: \(other.preferredKeywords.prefix(3).joined(separator: ", "))")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            Spacer()

                            Button(action: {
                                toggleFollow(userId: other.id)
                            }) {
                                Text(isFollowing(userId: other.id) ? "✓ Following" : "+ Follow")
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(isFollowing(userId: other.id) ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }

                        Divider()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .sheet(item: $selectedUser) { profile in
            WatchlistView(profile: profile)
                .environmentObject(userManager)
        }
        .sheet(item: $selectedRatingUser) { profile in
            UserRatingSheetView(profile: profile)
                .environmentObject(userManager)
        }
    }

    private func isFollowing(userId: String) -> Bool {
        userManager.user.similarUsers.contains(userId)
    }

    private func toggleFollow(userId: String) {
        if let index = userManager.user.similarUsers.firstIndex(of: userId) {
            userManager.user.similarUsers.remove(at: index)
        } else {
            userManager.user.similarUsers.append(userId)
        }
    }
}
