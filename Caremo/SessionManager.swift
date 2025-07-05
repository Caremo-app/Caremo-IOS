import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var selectedPersona: UserPersona?

    init() {
        // Cek apakah access_token ada di UserDefaults
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }

        // Load selected persona jika pernah disimpan sebelumnya
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
    }

    /// Logout function
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_persona")
        UserDefaults.standard.removeObject(forKey: "current_persona_email")

        selectedPersona = nil
        isLoggedIn = false

        print("✅ User logged out. All tokens and persona cleared.")
    }

    /// Call this when login is successful
    func loginSuccess() {
        isLoggedIn = true
    }
}
