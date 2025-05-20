import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("⚙️ Settings Tab")
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTabView()
}
