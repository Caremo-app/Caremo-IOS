import SwiftUI

struct SelectPersonaView: View {
    @State private var personas: [Persona] = []
    @State private var showingAddMember = false
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationView {
            VStack {
                Text("Siapa yang menggunakan Caremo hari ini?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding()

                if personas.isEmpty {
                    Text("Belum ada anggota terdaftar.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(personas) { persona in
                        Button(action: {
                            session.setPersona(persona)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(persona.name)
                                        .font(.headline)
                                        .foregroundColor(Color("PrimaryColor"))

                                    Text(persona.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: persona.relay ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundColor(persona.relay ? .green : .red)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                Spacer()

                Button(action: {
                    showingAddMember = true
                }) {
                    Text("Add Member")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("SecondaryColor"))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Pilih Pengguna")
            .sheet(isPresented: $showingAddMember, onDismiss: {
                fetchPersonas()
            }) {
                AddMemberView()
            }
            .onAppear {
                fetchPersonas()
            }
        }
    }

    func fetchPersonas() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ No access token found, logging out")
            DispatchQueue.main.async {
                session.logout()
            }
            return
        }

        guard let url = URL(string: "https://api.caremo.id/api/v1/family/list") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Fetch personas error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                print("❌ Token expired. Logging out...")
                DispatchQueue.main.async {
                    session.logout()
                }
                return
            }

            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Persona].self, from: data)
                    DispatchQueue.main.async {
                        personas = decoded
                        print("✅ Personas loaded: \(decoded.count)")
                    }
                } catch {
                    print("❌ Failed to decode personas: \(error)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw response: \(responseString)")
                    }
                }
            }
        }.resume()
    }
}
