import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var personaName: String = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Caremo Watch")
                .font(.headline)
            
            Text("Persona: \(personaName)")
                .font(.footnote)
            
            Button("Send ECG Sample") {
                sendDummyECG()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func sendDummyECG() {
        if WCSession.default.isReachable {
            let ecgSample = [0.95, 0.93, 0.90, 0.88]
            let message = ["ecg": ecgSample]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Error sending ECG: \(error.localizedDescription)")
            }
            print("✅ Sent ECG data: \(ecgSample)")
        } else {
            print("❌ iPhone not reachable")
        }
    }
}
