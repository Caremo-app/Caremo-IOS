import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionManager
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            if session.isLoggedIn {
                SelectPersonaView()
                    .environmentObject(session)
            } else {
                LoginView(showRegister: $showRegister)
                    .environmentObject(session)
                    .sheet(isPresented: $showRegister) {
                        RegisterView()
                    }
            }
        }
    }
}
