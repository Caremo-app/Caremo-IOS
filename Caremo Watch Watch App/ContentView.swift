import SwiftUI
import WatchConnectivity
import Combine
import CoreLocation

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var personaName: String = "-"
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
        
        NotificationCenter.default.publisher(for: .personaUpdated)
            .sink { [weak self] _ in
                self?.personaName = UserDefaults.standard.string(forKey: "persona_name") ?? "-"
            }
            .store(in: &cancellables)
        
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
        
        setupLocation()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
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
            
            Button("Start Predict") {
                startPredictTimer()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Simulate Family") {
                simulate(endpoint: "simulate-family")
            }
            .buttonStyle(.bordered)
            
            Button("Simulate Hospital") {
                simulate(endpoint: "simulate-hospital")
            }
            .buttonStyle(.bordered)
            
            Text("Lat: \(viewModel.latitude, specifier: "%.5f")")
            Text("Lng: \(viewModel.longitude, specifier: "%.5f")")
        }
        .padding()
        .onDisappear {
            stopPredictTimer()
        }
    }
    
    func startPredictTimer() {
        guard viewModel.personaName != "-" else {
            print("❌ Persona not synced. Cannot start predict.")
            return
        }
        
        isSending = true
        sendPredict()
        
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            sendPredict()
        }
        
        print("✅ Predict timer started")
    }
    
    func stopPredictTimer() {
        timer?.invalidate()
        timer = nil
        isSending = false
        print("🛑 Predict timer stopped")
    }
    
    func sendPredict() {
        let persona = viewModel.personaName
        let urlString = "https://api.caremo.id/api/v1/ai/predict?name_persona=\(persona)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
    func simulate(endpoint: String) {
        guard viewModel.personaName != "-" else {
            print("❌ Persona not synced. Cannot simulate.")
            return
        }
        
        let urlString = "https://api.caremo.id/api/v1/ai/\(endpoint)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Simulate \(endpoint) POST error: \(error.localizedDescription)")
                return
            }
            print("✅ Simulate \(endpoint) POST success")
        }.resume()
    }
}
