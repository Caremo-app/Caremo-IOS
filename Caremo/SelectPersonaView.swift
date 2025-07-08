import SwiftUI

struct SelectPersonaView: View {
    @State private var personas: [UserPersona] = []
    @State private var showingAddPersona = false
    @State private var isLoading = false
    
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all) // ✅ hilangkan putih tepi atas
                .overlay(BlurView(style: .systemUltraThinMaterialDark).opacity(0.4))
            
            VStack(spacing: 16) {
                Spacer().frame(height: 50) // jarak dari notch atas
                
                HStack {
                    Button(action: {
                        session.logout()
                    }) {
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
                
                // 🔄 Refresh Button
                Button(action: {
                    loadPersonas()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Persona")
                            .bold()
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
                                    GlassmorphismView {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(persona.name)
                                                    .font(CaremoTheme.Typography.subtitle)
                                                    .foregroundColor(.white)
                                                Text(persona.email)
                                                    .font(CaremoTheme.Typography.caption)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(height: 60)
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingAddPersona = true
                }) {
                    Text("Add Persona")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(CaremoTheme.primaryRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingAddPersona) {
            AddPersonaView(refreshPersonas: loadPersonas)
        }
        .onAppear(perform: loadPersonas)
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
        session.setPersona(persona)
        print("✅ Persona selected: \(persona.name)")
        // TODO: Navigate to DashboardView after selection if needed
    }
}
