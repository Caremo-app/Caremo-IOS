import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @Binding var showRegister: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea() // ✅ full background without white

            Color.black.opacity(0.4) // ✅ dark overlay for better branding
                .ignoresSafeArea()

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

                        Text("Login")
                            .font(CaremoTheme.Typography.title)
                            .foregroundColor(CaremoTheme.white)

                        TextField("Username", text: $username)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)

                        HStack {
                            Toggle("Remember me", isOn: $rememberMe)
                                .toggleStyle(CheckboxToggleStyle())
                                .foregroundColor(CaremoTheme.white)

                            Spacer()

                            Button("Forgot Password?") {
                                // action
                            }
                            .foregroundColor(CaremoTheme.white.opacity(0.7))
                            .font(CaremoTheme.Typography.caption)
                        }

                        Button(action: {
                            session.login(username: username, password: password)
                        }) {
                            Text("Login").bold()
                        }
                        .buttonStyle(CaremoTheme.ButtonStyle())

                        Button("Don't have an account? Register") {
                            showRegister = true
                        }
                        .foregroundColor(CaremoTheme.white.opacity(0.8))
                        .font(CaremoTheme.Typography.caption)
                    }
                    .padding()
                    .frame(width: 300)
                }
                .frame(maxHeight: 500)

                Spacer()
            }
        }
    }
}
