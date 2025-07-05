import SwiftUI

struct AddMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var role = "relay"
    @State private var isLoading = false

    var onAddMember: (() -> Void)? // ✅ callback refresh

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Info")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                }

                Section {
                    Button(action: addMember) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add Member")
                        }
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
            .navigationTitle("Add Member")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func addMember() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else { return }

        isLoading = true

        registerUser { success in
            if success {
                addMemberToFamily(token: token)
            } else {
                DispatchQueue.main.async {
                    isLoading = false
                    print("❌ Failed to register user before adding to family")
                }
            }
        }
    }

    func registerUser(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://api.caremo.id/api/v1/auth/signup?email=\(email)&password=defaultPassword123") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Signup error: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("✅ Signup success: \(responseString)")
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    func addMemberToFamily(token: String) {
        guard let url = URL(string: "https://api.caremo.id/api/v1/family/personas") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "role": role
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                print("❌ Add member error: \(error.localizedDescription)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("✅ Add member success: \(responseString)")
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                    onAddMember?() // ✅ call refresh
                }
            }
        }.resume()
    }
}
