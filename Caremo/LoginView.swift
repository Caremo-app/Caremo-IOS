import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Spacer()
                    .frame(height: 20) // memberi jarak atas agar logo tidak terlalu ke tengah
                
                Image("caremo_logo") // Pastikan logo sudah ada di Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 30) // menaikkan logo sedikit
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: {
                    login()
                }) {
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
                
                Spacer() // agar konten tetap proporsional saat keyboard muncul
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
                print(String(data: data, encoding: .utf8) ?? "")
            } else if let error = error {
                print("Login error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
