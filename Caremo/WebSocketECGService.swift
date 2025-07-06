import Foundation

class WebSocketECGService: NSObject {
    
    static let shared = WebSocketECGService()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    
    // MARK: - Connect to WebSocket backend
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
    
    // MARK: - Disconnect from backend
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        print("🛑 WebSocket disconnected")
    }
    
    // MARK: - Send ECG data in chunks
    func sendECG(ecg: [Double]) {
        guard let task = webSocketTask else {
            print("❌ WebSocket is not connected")
            return
        }
        
        let chunkSize = 1000 // Adjust based on backend preference
        let chunks = ecg.chunked(into: chunkSize)
        
        for (index, chunk) in chunks.enumerated() {
            do {
                let json: [String: Any] = [
                    "type": "ecg",
                    "data": chunk,
                    "sequence": index
                ]
                
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                let message = URLSessionWebSocketTask.Message.data(data)
                
                task.send(message) { error in
                    if let error = error {
                        print("❌ Error sending ECG chunk #\(index) over WebSocket: \(error.localizedDescription)")
                    } else {
                        print("✅ ECG chunk #\(index) sent to backend via WebSocket (\(chunk.count) samples)")
                    }
                }
            } catch {
                print("❌ Failed to encode ECG JSON chunk #\(index): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Listen for incoming WebSocket messages
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
                    print("⚠️ Received unknown WebSocket message type.")
                }
                self?.receive() // Continue listening
            case .failure(let error):
                print("❌ WebSocket receive error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Array Chunking Helper
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
