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
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📩 Received application context from iPhone: \(applicationContext)")
        
        if let type = applicationContext["type"] as? String {
            if type == "persona" {
                let name = applicationContext["name"] as? String ?? "-"
                let role = applicationContext["role"] as? String ?? "-"
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(name, forKey: "persona_name")
                    UserDefaults.standard.set(role, forKey: "persona_role")
                    NotificationCenter.default.post(name: .personaUpdated, object: nil)
                    print("✅ Persona saved: \(name) (\(role))")
                }
            } else if type == "token" {
                let token = applicationContext["access_token"] as? String ?? ""
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(token, forKey: "access_token")
                    print("✅ Token saved to UserDefaults")
                }
            }
        }
    }
    
    // Required for background transfers and message handling
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message from iPhone: \(message)")
    }
}
