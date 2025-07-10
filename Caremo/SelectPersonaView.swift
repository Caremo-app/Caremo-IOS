import SwiftUI

struct SelectPersonaView: View {
    @State private var personas: [UserPersona] = []
    @State private var showingAddPersona = false
    @State private var isLoading = false
    @State private var selectedPersonaID: Int?
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(BlurView(style: .systemUltraThinMaterialDark).opacity(0.4))
            
            VStack(spacing: 16) {
                Spacer().frame(height: 50)
                
                HStack {
                    Button(action: logout) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Logout")
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Text("Select Persona")
                    .font(CaremoTheme.Typography.title)
                    .foregroundColor(.white)
                
                Button(action: loadPersonas) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Persona").bold()
                    }
                    .padding(8)
                    .background(CaremoTheme.primaryRed.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(personas) { persona in
                                Button(action: {
                                    selectPersona(persona)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(persona.name)
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            
                                            Text(persona.role.capitalized)
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.subheadline)
                                        }
                                        Spacer()
                                        if persona.id == selectedPersonaID {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        ZStack {
                                            BlurView(style: .systemMaterialDark)
                                                .opacity(0.5)
                                            (persona.relay ? Color.blue : Color.purple)
                                                .opacity(0.3)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Button("Add New Persona") {
                    showingAddPersona = true
                }
                .buttonStyle(CaremoTheme.ButtonStyle())
                .sheet(isPresented: $showingAddPersona) {
                    AddPersonaView(refreshPersonas: loadPersonas)
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadPersonas()
        }
    }
    
    func loadPersonas() {
        isLoading = true
        APIManager.shared.getFamilyPersonas { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    personas = data
                    print("✅ Loaded \(data.count) personas")
                case .failure(let error):
                    print("❌ Failed to load personas: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func selectPersona(_ persona: UserPersona) {
        selectedPersonaID = persona.id
        UserDefaults.standard.set(persona.id, forKey: "selectedPersonaID")
        UserDefaults.standard.set(persona.name, forKey: "selectedPersonaName")
        print("✅ Selected persona: \(persona.name)")
        session.selectedPersona = persona
    }
    
    func logout() {
        session.logout()
    }
}
