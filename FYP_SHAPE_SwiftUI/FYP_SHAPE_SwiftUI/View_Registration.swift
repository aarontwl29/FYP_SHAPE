import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword
    }

    var isPasswordValid: Bool {
        password.count >= 8
    }

    var isPasswordMatching: Bool {
        confirmPassword == password && !confirmPassword.isEmpty
    }

    var body: some View {
        VStack(spacing: 18) {
            
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

            emailField()

            passwordField(
                title: "Password",
                text: $password,
                isVisible: $isPasswordVisible,
                focused: $focusedField,
                field: .password,
                showSuccess: isPasswordValid,
                successText: "Password is secure",
                showError: false,
                errorText: ""
            )

            passwordField(
                title: "Confirm Password",
                text: $confirmPassword,
                isVisible: $isConfirmPasswordVisible,
                focused: $focusedField,
                field: .confirmPassword,
                showSuccess: isPasswordMatching,
                successText: "Passwords match",
                showError: !isPasswordMatching && !confirmPassword.isEmpty,
                errorText: "Please make sure both passwords are the same"
            )

            (
                Text("By registering, you agree to our ") +
                Text("Terms of Service").fontWeight(.bold).foregroundColor(.blue) +
                Text(" and ") +
                Text("Privacy Policy").fontWeight(.bold).foregroundColor(.blue)
            )
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding(.top, 4)

            Button(action: {
            }) {
                Text("Verify Email")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .bold()
            }
            .padding(.top, 6)

            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(.footnote)
                NavigationLink(destination: LoginView(onLoginSuccess: {})) {
                    Text("Log in")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .bold(true)
                }
            }
            .padding(.bottom, 10)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.white)
    }

    @ViewBuilder
    func emailField() -> some View {
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
            .frame(minHeight: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(focusedField == .email ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
    }

    @ViewBuilder
    func passwordField(
        title: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        focused: FocusState<Field?>.Binding,
        field: Field,
        showSuccess: Bool,
        successText: String,
        showError: Bool,
        errorText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)

            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)

                if isVisible.wrappedValue {
                    TextField("Enter your password", text: text)
                        .focused(focused, equals: field)
                } else {
                    SecureField("Enter your password", text: text)
                        .focused(focused, equals: field)
                }

                Button(action: {
                    isVisible.wrappedValue.toggle()
                }) {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(minHeight: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        focused.wrappedValue == field ? Color.blue :
                        showError ? Color.red :
                        showSuccess ? Color.green :
                        Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)

            if showSuccess {
                messageBox(icon: "checkmark.circle", text: successText, color: .green, bgColor: Color.green.opacity(0.1))
            } else if showError {
                messageBox(icon: "exclamationmark.triangle", text: errorText, color: .red, bgColor: Color.red.opacity(0.1))
            } else {
                messageBox(icon: "info.circle", text: "At least 8 characters", color: .blue, bgColor: Color.blue.opacity(0.05))
            }
        }
    }

    @ViewBuilder
    func messageBox(icon: String, text: String, color: Color, bgColor: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(bgColor)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        RegisterView()
    }
}
