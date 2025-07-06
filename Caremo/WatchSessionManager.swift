import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchSessionManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("✅ WatchSessionManager initialized and activated.")
        }
    }
    
    // MARK: - WCSessionDelegate
    
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
        print("ℹ️ Watch session did deactivate.")
        WCSession.default.activate()
    }
    
    /// Receive message from Watch app
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message from Watch: \(message)")
        
        if let ecg = message["ecg"] as? [Double] {
            print("💓 ECG data received: \(ecg)")
            WebSocketECGService.shared.sendECG(ecg: ecg)
        }
    }
    
    /// Sync persona to Watch app
    func syncPersonaToWatch(persona: UserPersona) {
        guard WCSession.default.isReachable else {
            print("❌ Watch not reachable. Cannot sync persona.")
            return
        }
        
        let data: [String: Any] = [
            "type": "persona",
            "name": persona.name,
            "email": persona.email,
            "role": persona.role
        ]
        
        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            print("❌ Failed to send persona to Watch: \(error.localizedDescription)")
        }
        
        print("✅ Persona sent to Watch: \(persona.name)")
    }
}
