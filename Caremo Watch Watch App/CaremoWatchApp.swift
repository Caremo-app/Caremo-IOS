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
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("📩 Received application context from iPhone: \(applicationContext)")
        
        guard let type = applicationContext["type"] as? String, type == "persona" else { return }
        
        let name = applicationContext["name"] as? String ?? "-"
        
        DispatchQueue.main.async {
            UserDefaults.standard.set(name, forKey: "persona_name")
            NotificationCenter.default.post(name: .personaUpdated, object: nil)
            
            print("✅ Persona saved to UserDefaults: \(name)")
        }
    }
}
