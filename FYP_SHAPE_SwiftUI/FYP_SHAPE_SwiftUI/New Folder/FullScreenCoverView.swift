import SwiftUI

struct FullScreenCoverView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("🧊 Full Screen Cover")
            Button("Close") {
                dismiss()
            }
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    FullScreenCoverView()
}
