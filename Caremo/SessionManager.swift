import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedPersona: UserPersona?

    init() {
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }

        if let name = UserDefaults.standard.string(forKey: "current_persona"),
           let email = UserDefaults.standard.string(forKey: "current_persona_email") {
            selectedPersona = UserPersona(id: -1, name: name, email: email, role: "relay")
        }
    }

    func setPersona(_ persona: UserPersona) {
        selectedPersona = persona
        UserDefaults.standard.set(persona.name, forKey: "current_persona")
        UserDefaults.standard.set(persona.email, forKey: "current_persona_email")

        WatchSessionManager.shared.syncPersonaToWatch(persona: persona)
        print("✅ Persona set: \(persona.name)")
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
