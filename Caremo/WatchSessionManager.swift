import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        guard WCSession.isSupported() else {
            print("❌ WCSession not supported on this device.")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("✅ WatchSessionManager initialized and WCSession activated.")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ iOS Watch session activated with state: \(activationState.rawValue)")
        if let error = error {
            print("❌ WCSession activation error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("ℹ️ Watch session did become inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("ℹ️ Watch session did deactivate. Reactivating...")
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("📩 Received message from Watch: \(message)")
        
        if message["request"] as? String == "current_persona" {
            // ✅ Retrieve current persona from UserDefaults (standardized keys)
            let personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
            let personaRole = UserDefaults.standard.string(forKey: "persona_role") ?? "-"
            
            let response: [String: Any] = [
                "name": personaName,
                "role": personaRole
            ]
            
            replyHandler(response)
            print("✅ Sent current persona to Watch: \(personaName) (\(personaRole))")
        }
    }
    
    func syncPersonaToWatch(persona: UserPersona) {
        let data: [String: Any] = [
            "type": "persona",
            "name": persona.name,
            "email": persona.email,
            "role": persona.role
        ]
        
        let session = WCSession.default
        
        print("isPaired: \(session.isPaired), isWatchAppInstalled: \(session.isWatchAppInstalled)")
        
        guard session.isPaired else {
            print("❌ Apple Watch is not paired. Cannot sync persona.")
            return
        }
        
        guard session.isWatchAppInstalled else {
            print("❌ Watch app is not installed. Cannot sync persona.")
            return
        }
        
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil) { error in
                print("❌ Failed to send persona to Watch: \(error.localizedDescription)")
            }
            print("✅ Persona sent to Watch via sendMessage: \(persona.name) (\(persona.role))")
        } else {
            do {
                try session.updateApplicationContext(data)
                print("✅ Persona updated via ApplicationContext: \(persona.name) (\(persona.role))")
            } catch {
                print("❌ Failed to update ApplicationContext: \(error.localizedDescription)")
            }
        }
    }
}
