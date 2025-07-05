import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

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
                } else {
                    Text("No persona selected.")
                        .foregroundColor(.gray)
                }

                Spacer()

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

                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let dummySession = SessionManager()
        dummySession.selectedPersona = Persona(id: 1, name: "Rafi", email: "rafi@caremo.id", role: "relay")
        return DashboardView()
            .environmentObject(dummySession)
    }
}
