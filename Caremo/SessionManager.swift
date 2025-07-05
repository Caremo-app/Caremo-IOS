import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedPersona: Persona?

    init() {
        isLoggedIn = UserDefaults.standard.string(forKey: "access_token") != nil

        if let name = UserDefaults.standard.string(forKey: "current_persona"),
           let email = UserDefaults.standard.string(forKey: "current_persona_email") {
            selectedPersona = Persona(id: -1, name: name, email: email, role: "relay")
        }
    }

    func setPersona(_ persona: Persona) {
        selectedPersona = persona
        UserDefaults.standard.set(persona.name, forKey: "current_persona")
        UserDefaults.standard.set(persona.email, forKey: "current_persona_email")
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_persona")
        UserDefaults.standard.removeObject(forKey: "current_persona_email")

        selectedPersona = nil
        isLoggedIn = false

        print("✅ User logged out. All tokens and persona cleared.")
    }

    func loginSuccess() {
        isLoggedIn = true
    }
}
