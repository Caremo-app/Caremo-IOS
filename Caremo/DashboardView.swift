import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Persona info
                if let persona = session.selectedPersona {
                    VStack(spacing: 10) {
                        Text("Welcome, \(persona.name)!")
                            .font(.title2)
                            .foregroundColor(Color("PrimaryColor"))

                        Text("Email: \(persona.email)")
                            .foregroundColor(.gray)

                        Text("Role: \(persona.role.capitalized)")
                            .foregroundColor(persona.relay ? .green : .red)
                    }
                    .padding()
                } else {
                    Text("No persona selected.")
                        .foregroundColor(.gray)
                }

                Divider()

                // ECG section placeholder
                VStack(spacing: 10) {
                    Text("ECG Monitoring")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryColor"))

                    Text("Waiting for ECG data...")
                        .foregroundColor(.gray)
                }
                .padding()

                Spacer()

                // Logout button
                Button(action: {
                    session.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let dummySession = SessionManager()
        dummySession.selectedPersona = UserPersona(id: 1, name: "Rafi", email: "rafi@caremo.id", role: "relay")
        return DashboardView()
            .environmentObject(dummySession)
    }
}
