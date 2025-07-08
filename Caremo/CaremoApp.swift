import SwiftUI

@main
struct CaremoApp: App {
    @StateObject var session = SessionManager()
    @State private var showSplash = true

    init() {
        // Activate WatchSessionManager & WebSocket on launch
        _ = WatchSessionManager.shared
        WebSocketECGService.shared.connect(clientID: "1")
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplash = false
                        }
                    }
            } else {
                RootView()
                    .environmentObject(session)
            }
        }
    }
}
