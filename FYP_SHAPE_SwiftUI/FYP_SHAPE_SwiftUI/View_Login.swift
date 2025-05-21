import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    @FocusState private var focusedField: Field?
    enum Field {
        case email
        case password
    }
    
    var onLoginSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
            
            VStack(spacing: 4) {
                Text("Discover What’s New on")
                    .font(.headline)
                Text("Review33")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption)
                    .fontWeight(.semibold)
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .email)
                }
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField == .email ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
            
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .fontWeight(.semibold)
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    if isPasswordVisible {
                        TextField("Enter your password", text: $password)
                            .focused($focusedField, equals: .password)
                    } else {
                        SecureField("Enter your password", text: $password)
                            .focused($focusedField, equals: .password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(focusedField == .password ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
            
            
            Button(action: {
                onLoginSuccess()
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .bold(true)
            }
            
            Button(action: {}) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .bold()
            }
            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4))
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4))
            }
            
            VStack(spacing: 10) {
                SocialLoginButton(imageName: "google", text: "Sign in with Google")
                SocialLoginButton(imageName: "facebook", text: "Sign in with Facebook")
                SocialLoginButton(imageName: "apple", text: "Sign in with Apple")
            }
            
            Spacer(minLength: 10)
            
            HStack {
                Text("Don't have an account?")
                    .font(.footnote)
                NavigationLink(destination: RegisterView()) {
                    Text("Sign Up")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}


struct SocialLoginButton: View {
    let imageName: String
    let text: String
    
    var body: some View {
        Button(action: {
    
        }) {
            HStack(spacing: 12) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                Text(text)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
}


#Preview {
    NavigationView {
        LoginView(onLoginSuccess: {})
    }
}
