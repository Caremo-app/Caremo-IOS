import SwiftUI

struct LoginResponse: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let email: String
}

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Image("caremo_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 30)

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                Button(action: { login() }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(8)
                }

                Button(action: {
                    showingRegister = true
                }) {
                    Text("Don’t have an account? Register")
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                }
                .sheet(isPresented: $showingRegister) {
                    RegisterView()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    func login() {
        guard let url = URL(string: "https://api.caremo.id/api/v1/auth/signin?email=\(email)&password=\(password)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    UserDefaults.standard.set(decoded.access_token, forKey: "access_token")
                    UserDefaults.standard.set(decoded.refresh_token, forKey: "refresh_token")
                    DispatchQueue.main.async {
                        session.loginSuccess()
                        print("✅ Login success. Token saved.")
                    }
                } catch {
                    print("❌ Failed to decode login response: \(error)")
                }
            } else if let error = error {
                print("❌ Login error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
