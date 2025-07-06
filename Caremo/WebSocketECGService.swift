import Foundation

class WebSocketECGService: NSObject {
    
    static let shared = WebSocketECGService()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    
    func connect(clientID: String) {
        guard webSocketTask == nil else { return }
        
        let urlString = "wss://api.caremo.id/ws/send/\(clientID)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("✅ WebSocket connected to backend: \(urlString)")
        receive()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        print("🛑 WebSocket disconnected")
    }
    
    func sendECG(ecg: [Double]) {
        guard let task = webSocketTask else {
            print("❌ WebSocket is not connected")
            return
        }
        
        do {
            let json: [String: Any] = ["type": "ecg", "data": ecg]
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let message = URLSessionWebSocketTask.Message.data(data)
            
            task.send(message) { error in
                if let error = error {
                    print("❌ Error sending ECG over WebSocket: \(error.localizedDescription)")
                } else {
                    print("✅ ECG sent to backend via WebSocket (\(ecg.count) samples)")
                }
            }
        } catch {
            print("❌ Failed to encode ECG JSON: \(error.localizedDescription)")
        }
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("📩 Received data: \(data)")
                case .string(let text):
                    print("📩 Received text: \(text)")
                @unknown default:
                    break
                }
                self?.receive()
            case .failure(let error):
                print("❌ WebSocket receive error: \(error.localizedDescription)")
            }
        }
    }
}
