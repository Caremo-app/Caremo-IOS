import SwiftUI

struct SelectPersonaView: View {
    @State private var personas: [UserPersona] = []
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
                            selectPersona(persona)
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
                    fetchPersonas()
                }) {
                    Text("Refresh Members")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    fetchPersonas()
                }
            }) {
                AddMemberView()
            }
            .onAppear {
                fetchPersonas()
            }
            .fullScreenCover(item: $session.selectedPersona) { _ in
                DashboardView()
                    .environmentObject(session)
            }
        }
    }

    // MARK: - Persona Selection Handler

    func selectPersona(_ persona: UserPersona) {
        session.setPersona(persona)
        print("✅ Persona selected: \(persona.name)")

        // Sync to Watch
        WatchSessionManager.shared.syncPersonaToWatch(persona: persona)
    }

    // MARK: - Fetch Personas API

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

            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw personas response: \(responseString)")
                }

                if let decodedError = try? JSONDecoder().decode([String: String].self, from: data),
                   decodedError["detail"] == "Access token expired" {
                    print("❌ Token expired. Logging out...")
                    DispatchQueue.main.async {
                        session.logout()
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode([UserPersona].self, from: data)
                    DispatchQueue.main.async {
                        personas = decoded
                        print("✅ Personas loaded: \(decoded.count)")
                    }
                } catch {
                    print("❌ Failed to decode personas: \(error)")
                }
            }
        }.resume()
    }
}
