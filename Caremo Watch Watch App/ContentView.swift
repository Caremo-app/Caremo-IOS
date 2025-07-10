import SwiftUI
import WatchConnectivity
import Combine
import CoreLocation

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var personaName: String = "-"
    @Published var personaRole: String = "-"
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var token: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        // Load saved persona and token
        personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
        personaRole = UserDefaults.standard.string(forKey: "persona_role") ?? "-"
        token = UserDefaults.standard.string(forKey: "access_token") ?? "-"
        
        // Observe persona updates
        NotificationCenter.default.publisher(for: .personaUpdated)
            .sink { [weak self] _ in
                self?.personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
                self?.personaRole = UserDefaults.standard.string(forKey: "persona_role") ?? "-"
                print("🔄 Persona updated in ViewModel: \(self?.personaName ?? "-") (\(self?.personaRole ?? "-"))")
            }
            .store(in: &cancellables)
        
        // Activate WCSession
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
        
        setupLocation()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("📍 Location setup initialized.")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            print("❌ No locations received.")
            return
        }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        print("✅ Updated location: \(latitude), \(longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager error: \(error.localizedDescription)")
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
        ScrollView {
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Text("Caremo Watch")
                        .font(.headline)
                    
                    VStack(spacing: 4) {
                        Text("Persona: \(viewModel.personaName)")
                            .font(.footnote)
                        Text("Role: \(viewModel.personaRole.capitalized)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    Button("Refresh Persona") {
                        refreshPersona()
                    }
                    .buttonStyle(.bordered)
                    
                    if viewModel.personaRole == "relay" {
                        Button("Start Predict") {
                            startPredictTimer()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // 🔧 Updated Simulate Critical Condition button
                        Button("Simulate Critical Condition") {
                            simulateCriticalCondition()
                        }
                        .buttonStyle(.bordered)
                        
                        // Lat/Lng display removed as requested
                        
                    } else {
                        Text("Only relay personas are allowed to use this feature.\nPlease pick a relay persona on iPhone.")
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .onDisappear {
            stopPredictTimer()
        }
    }
    
    // MARK: - Helper Functions
    
    func refreshPersona() {
        viewModel.personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
        viewModel.personaRole = UserDefaults.standard.string(forKey: "persona_role") ?? "-"
        print("🔄 Refreshed persona: \(viewModel.personaName) (\(viewModel.personaRole))")
    }
    
    func startPredictTimer() {
        guard viewModel.personaName != "-" else {
            print("❌ Persona not synced.")
            return
        }
        guard !viewModel.token.isEmpty else {
            print("❌ Token missing.")
            return
        }
        
        isSending = true
        sendPredict()
        
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            sendPredict()
        }
        print("⏱️ Predict timer started.")
    }
    
    func stopPredictTimer() {
        timer?.invalidate()
        timer = nil
        isSending = false
        print("⏹️ Predict timer stopped.")
    }
    
    func sendPredict() {
        let persona = viewModel.personaName
        let urlString = "https://api.caremo.id/api/v1/ai/predict?name_persona=\(persona)"
        guard let url = URL(string: urlString) else { return }
        guard !viewModel.token.isEmpty else {
            print("❌ Token missing.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "ppg_input": [
                "signal": [0.12, 0.14, 0.13, 0.15],
                "heartbeat": 90,
                "sampling_rate": 250
            ],
            "location": [
                "latitude": viewModel.latitude,
                "longitude": viewModel.longitude
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ JSON encoding error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Predict POST error: \(error.localizedDescription)")
                return
            }
            print("✅ Predict POST success")
        }.resume()
    }
    
    func simulateCriticalCondition() {
        guard viewModel.personaName != "-" else {
            print("❌ Persona not synced.")
            return
        }
        guard !viewModel.token.isEmpty else {
            print("❌ Token missing.")
            return
        }
        
        // 🔧 Endpoint: /api/v1/ai/simulate-critical-condition?name_persona=...
        let urlString = "https://api.caremo.id/api/v1/ai/simulate-critical-condition?name_persona=\(viewModel.personaName)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(viewModel.token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "latitude": viewModel.latitude,
            "longitude": viewModel.longitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ JSON encoding error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Simulate Critical Condition POST error: \(error.localizedDescription)")
                return
            }
            print("✅ Simulate Critical Condition POST success")
        }.resume()
    }
}
