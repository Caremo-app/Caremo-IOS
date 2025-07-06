import SwiftUI
import WatchConnectivity
import Combine

class ContentViewModel: ObservableObject {
    @Published var personaName: String = "-"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
        
        NotificationCenter.default.publisher(for: .personaUpdated)
            .sink { [weak self] _ in
                self?.personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
            }
            .store(in: &cancellables)
        
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
}

extension Notification.Name {
    static let personaUpdated = Notification.Name("personaUpdated")
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var timer: Timer?
    @State private var isSending = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Caremo Watch")
                .font(.headline)
            
            Text("Persona: \(viewModel.personaName)")
                .font(.footnote)
            
            Button("Refresh Persona") {
                viewModel.personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
            }
            .buttonStyle(.bordered)
            
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
    }
    
    func startECGTimer() {
        guard viewModel.personaName != "-" else {
            print("❌ Persona not synced. Cannot start ECG.")
            return
        }
        
        isSending = true
        sendECGData()
        
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
            print(message)
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("❌ Error sending ECG: \(error.localizedDescription)")
            }
            print("✅ Sent ECG data (\(ecgSample.count) samples) to iOS")
        } else {
            print("❌ iPhone not reachable")
        }
    }
    
    func generateDummyECG30s() -> [Double] {
        (0..<300).map { _ in Double.random(in: 0.8...1.2) }
    }
}
