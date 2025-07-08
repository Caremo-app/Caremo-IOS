import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedPersona: UserPersona?

    init() {
        // Check if access_token exists on app launch
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }

        // Restore selected persona if exists
        if let name = UserDefaults.standard.string(forKey: "current_persona"),
           let email = UserDefaults.standard.string(forKey: "current_persona_email") {
            selectedPersona = UserPersona(id: -1, name: name, email: email, role: "relay")
        }
    }

    /// Sets the current persona and syncs it to the Watch app
    func setPersona(_ persona: UserPersona) {
        selectedPersona = persona
        UserDefaults.standard.set(persona.name, forKey: "current_persona")
        UserDefaults.standard.set(persona.email, forKey: "current_persona_email")

        WatchSessionManager.shared.syncPersonaToWatch(persona: persona)
        print("✅ Persona set: \(persona.name)")
    }

    /// Clears login state and user defaults for logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_persona")
        UserDefaults.standard.removeObject(forKey: "current_persona_email")

        selectedPersona = nil
        isLoggedIn = false

        print("✅ User logged out. All tokens and persona cleared.")
    }

    /// Marks login success
    func loginSuccess() {
        isLoggedIn = true
    }

    /// New: Handles login logic from LoginView
    func login(username: String, password: String) {
        // 🔧 TODO: Replace with actual API call for production
        print("🔐 Attempting login with username: \(username), password: \(password)")

        // Simulate successful login for now
        UserDefaults.standard.set("dummy_access_token", forKey: "access_token")
        self.isLoggedIn = true

        print("✅ Login success for user: \(username)")
    }
}
