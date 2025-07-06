import SwiftUI

@main
struct CaremoApp: App {
    @StateObject var session = SessionManager()
    
    init() {
        // Activate WatchSessionManager & WebSocket on launch
        _ = WatchSessionManager.shared
        WebSocketECGService.shared.connect()
    }
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                SelectPersonaView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}
