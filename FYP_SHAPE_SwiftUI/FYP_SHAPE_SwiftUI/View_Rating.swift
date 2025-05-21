import SwiftUI

extension Notification.Name {
    static let didRateMovie = Notification.Name("didRateMovie")
}

struct RatingInputView: View {
    @EnvironmentObject var userManager: UserManager
    let movieTitle: String

    @Binding var isPresented: Bool
    @State private var selectedRating: Int = 5

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Your Rating:")
                    .font(.title2)
                    .bold()

                // Rating Scale: 1 to 10
                Picker("Rating", selection: $selectedRating) {
                    ForEach(1...10, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

                Button(action: {
                    userManager.user.ratedMovies[movieTitle] = selectedRating
                    print(userManager.debugSummary())
                    NotificationCenter.default.post(name: .didRateMovie, object: movieTitle)
                    isPresented = false
                }) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Rate This Movie")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
