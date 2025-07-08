import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    BlurView(style: .systemUltraThinMaterialDark)
                )

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
                            .foregroundColor(CaremoTheme.white)

                        TextField("Name", text: $name)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)

                        TextField("Email", text: $email)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)

                        Button(action: {
                            print("Register user: \(name), email: \(email)")
                        }) {
                            Text("Register").bold()
                        }
                        .buttonStyle(CaremoTheme.ButtonStyle())

                        Button("Already have an account? Login") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(CaremoTheme.white.opacity(0.8))
                        .font(CaremoTheme.Typography.caption)
                    }
                    .padding()
                    .frame(width: 300) // ✅ Smaller compact width
                }
                .frame(maxHeight: 600) // ✅ Compact height

                Spacer()
            }
        }
    }
}
