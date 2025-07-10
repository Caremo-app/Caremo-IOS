import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("✅ Watch WCSession activated.")
        }
    }
    
    // MARK: - App Lifecycle
    
    func applicationDidFinishLaunching() {
        print("✅ Watch application did finish launching.")
    }
    
    func applicationDidBecomeActive() {
        print("✅ Watch application did become active.")
    }
    
    func applicationWillResignActive() {
        print("⚠️ Watch application will resign active.")
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ Watch session activated with state: \(activationState.rawValue)")
        if let error = error {
            print("❌ Watch session activation error: \(error.localizedDescription)")
        }
    }
    
    /// ApplicationContext updates
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📩 Received application context from iPhone: \(applicationContext)")
        handlePersonaData(applicationContext)
    }
    
    /// sendMessage handling
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message from iPhone: \(message)")
        handlePersonaData(message)
    }
    
    /// Helper to process persona data consistently
    private func handlePersonaData(_ data: [String: Any]) {
        if let type = data["type"] as? String, type == "persona" {
            let name = data["name"] as? String ?? "-"
            let role = data["role"] as? String ?? "-"
            
            DispatchQueue.main.async {
                UserDefaults.standard.set(name, forKey: "persona_name")
                UserDefaults.standard.set(role, forKey: "persona_role")
                NotificationCenter.default.post(name: .personaUpdated, object: nil)
                print("✅ Persona saved: \(name) (\(role))")
            }
        } else if let type = data["type"] as? String, type == "token" {
            let token = data["access_token"] as? String ?? ""
            
            DispatchQueue.main.async {
                UserDefaults.standard.set(token, forKey: "access_token")
                print("✅ Token saved to UserDefaults")
            }
        }
    }
}
