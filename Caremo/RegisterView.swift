import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Register")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }

                Button("Register") {
                    register()
                }
            }
            .navigationTitle("Register")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func register() {
        guard let url = URL(string: "https://api.caremo.id/api/v1/auth/signup?email=\(email)&password=\(password)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("✅ Register response: \(String(data: data, encoding: .utf8) ?? "")")
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } else if let error = error {
                print("❌ Register error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
