import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var personaName: String = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
    @State private var timer: Timer?
    @State private var isSending = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Caremo Watch")
                .font(.headline)
            
            Text("Persona: \(personaName)")
                .font(.footnote)
            
            if isSending {
                Text("💓 Sending ECG every 30s")
                    .foregroundColor(.green)
                
                Button("Stop ECG Auto-Send") {
                    stopECGTimer()
                }
                .buttonStyle(.bordered)
            } else {
                Button("Start ECG Auto-Send") {
                    startECGTimer()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onDisappear {
            stopECGTimer()
        }
        .onAppear {
            // Update persona name every appear (in case synced after launch)
            personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
        }
    }
    
    func startECGTimer() {
        guard personaName != "-" else {
            print("❌ Persona not synced. Cannot start ECG.")
            return
        }
        
        isSending = true
        sendECGData() // Send immediately
        
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            sendECGData()
        }
        
        print("✅ ECG auto-send timer started")
    }
    
    func stopECGTimer() {
        timer?.invalidate()
        timer = nil
        isSending = false
        print("🛑 ECG auto-send timer stopped")
    }
    
    func sendECGData() {
        if WCSession.default.isReachable {
            let ecgSample = generateDummyECG30s()
            let message = ["ecg": ecgSample]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Error sending ECG: \(error.localizedDescription)")
            }
            print("✅ Sent ECG data (\(ecgSample.count) samples) to iOS")
        } else {
            print("❌ iPhone not reachable")
        }
    }
    
    func generateDummyECG30s() -> [Double] {
        // Simulate 30s ECG at 250Hz = 7500 samples
        (0..<7500).map { _ in Double.random(in: 0.8...1.2) }
    }
}
