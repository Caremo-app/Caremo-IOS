import SwiftUI

@main
struct CaremoApp: App {
    @StateObject var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                // Jika sudah login ➔ ke SelectPersonaView
                SelectPersonaView()
                    .environmentObject(session)
            } else {
                // Jika belum login ➔ ke LoginView
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}
