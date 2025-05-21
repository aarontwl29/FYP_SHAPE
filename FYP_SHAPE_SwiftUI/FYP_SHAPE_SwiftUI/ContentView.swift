import SwiftUI

struct AppRootView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LoginView {
                isLoggedIn = true
            }
        }
    }
}

#Preview {
    AppRootView()
}
