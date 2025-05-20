import SwiftUI

struct SampleSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("📝 This is a Sheet")
            Button("Close") {
                dismiss()
            }
        }
        .padding()
    }
}

#Preview {
    SampleSheetView()
}
