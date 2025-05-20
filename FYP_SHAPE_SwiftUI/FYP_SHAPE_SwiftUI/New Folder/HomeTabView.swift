import SwiftUI

struct HomeTabView: View {
    @State private var showSheet = false
    @State private var showFullCover = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Text("🏠 Home Tab")

                Button("🔼 Push to Detail View") {
                    path.append("DetailView")
                }

                Button("📄 Open Sheet") {
                    showSheet = true
                }

                Button("🧊 Full Screen Cover") {
                    showFullCover = true
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showSheet) {
                SampleSheetView()
            }
            .fullScreenCover(isPresented: $showFullCover) {
                FullScreenCoverView()
            }
            .navigationDestination(for: String.self) { value in
                if value == "DetailView" {
                    DetailView()
                }
            }
        }
    }
}

#Preview {
    HomeTabView()
}
