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
    
    func login(username: String, password: String) {
        print("🔐 Attempting login with username: \(username)")
        
        let loginBody: [String: Any] = [
            "email": username,
            "password": password
        ]
        
        APIManager.shared.postNoAuth(endpoint: "/api/v1/auth/signin", body: loginBody) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let accessToken = json["access_token"] as? String,
                           let refreshToken = json["refresh_token"] as? String {
                            UserDefaults.standard.set(accessToken, forKey: "access_token")
                            UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
                            self.isLoggedIn = true
                            print("✅ Login success. Token saved.")
                        } else {
                            print("❌ Invalid login response format: \(String(describing: String(data: data, encoding: .utf8)))")
                        }
                    } catch {
                        print("❌ Failed to parse login response: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("❌ Login API call failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
