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

    /// Set persona saat user memilih di SelectPersonaView
    func setPersona(_ persona: UserPersona) {
        selectedPersona = persona
        UserDefaults.standard.set(persona.name, forKey: "current_persona")
        UserDefaults.standard.set(persona.email, forKey: "current_persona_email")
        
        // Sync to Watch
        WatchSessionManager.shared.syncPersonaToWatch(persona: persona)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_persona")
        UserDefaults.standard.removeObject(forKey: "current_persona_email")

        selectedPersona = nil
        isLoggedIn = false
        
        WebSocketECGService.shared.disconnect()
        
        print("✅ User logged out. All tokens, persona, and websocket cleared.")
    }

    func loginSuccess() {
        isLoggedIn = true
    }
}
