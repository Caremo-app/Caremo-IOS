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
        print("ℹ️ Watch session did deactivate. Reactivating...")
        session.activate()
    }
    
    // MARK: - Receiving Messages from Watch
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message from Watch: \(message)")
        
        if let ecg = message["ecg"] as? [Double] {
            print("💓 ECG data received: \(ecg.count) samples")
            WebSocketECGService.shared.sendECG(ecg: ecg)
        }
    }
    
    // MARK: - Sync Persona to Watch
    
    func syncPersonaToWatch(persona: UserPersona) {
        let data: [String: Any] = [
            "type": "persona",
            "name": persona.name,
            "email": persona.email,
            "role": persona.role
        ]
        
        let session = WCSession.default
        
        guard session.isPaired else {
            print("❌ Apple Watch is not paired. Cannot sync persona.")
            return
        }
        
        guard session.isWatchAppInstalled else {
            print("❌ Watch app is not installed. Cannot sync persona.")
            return
        }
        
        if session.isReachable {
            // Immediate send if Watch app is active
            session.sendMessage(data, replyHandler: nil) { error in
                print("❌ Failed to send persona to Watch: \(error.localizedDescription)")
            }
            print("✅ Persona sent to Watch via sendMessage: \(persona.name)")
        } else {
            // Application Context fallback (state sync)
            do {
                try session.updateApplicationContext(data)
                print("✅ Persona updated via ApplicationContext: \(persona.name)")
            } catch {
                print("❌ Failed to update ApplicationContext: \(error.localizedDescription)")
            }
        }
    }
}
