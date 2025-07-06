import SwiftUI
import WatchConnectivity
import WatchKit

@main
struct CaremoWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ Watch session activated with state: \(activationState.rawValue)")
        if let error = error {
            print("❌ Watch session activation error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Receive application context sync (persona)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📩 Received application context from iPhone: \(applicationContext)")
        
        if let type = applicationContext["type"] as? String, type == "persona" {
            let name = applicationContext["name"] as? String ?? "-"
            let email = applicationContext["email"] as? String ?? "-"
            let role = applicationContext["role"] as? String ?? "-"
            
            print("✅ Persona synced from iPhone (applicationContext):")
            print("Name: \(name), Email: \(email), Role: \(role)")
            
            UserDefaults.standard.set(name, forKey: "persona_name")
            UserDefaults.standard.set(email, forKey: "persona_email")
            UserDefaults.standard.set(role, forKey: "persona_role")
            
            NotificationCenter.default.post(name: .personaUpdated, object: nil)
        }
    }
    
    // MARK: - Optional: Receive direct messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message from iPhone: \(message)")
        
        if let type = message["type"] as? String, type == "persona" {
            let name = message["name"] as? String ?? "-"
            let email = message["email"] as? String ?? "-"
            let role = message["role"] as? String ?? "-"
            
            print("✅ Persona synced from iPhone (message):")
            print("Name: \(name), Email: \(email), Role: \(role)")
            
            UserDefaults.standard.set(name, forKey: "persona_name")
            UserDefaults.standard.set(email, forKey: "persona_email")
            UserDefaults.standard.set(role, forKey: "persona_role")
            
            NotificationCenter.default.post(name: .personaUpdated, object: nil)
        }
    }
}
