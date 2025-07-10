import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(BlurView(style: .systemUltraThinMaterialDark).opacity(0.4))

            VStack {
                Spacer()
                GlassmorphismView {
                    VStack(spacing: 16) {
                        Image("caremo_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)

                        Text("Register")
                            .font(CaremoTheme.Typography.title)
                            .foregroundColor(.white)

                        TextField("Name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Button(action: register) {
                                Text("Register").bold()
                            }
                            .buttonStyle(CaremoTheme.ButtonStyle())
                            .disabled(email.isEmpty || password.isEmpty || password != confirmPassword)
                        }

                        Button("Already have an account? Login") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .font(CaremoTheme.Typography.caption)
                    }
                    .padding()
                    .frame(width: 300)
                }
                Spacer()
            }
        }
    }

    func register() {
        isLoading = true
        APIManager.shared.register(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    print("✅ Registration successful")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Registration failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
