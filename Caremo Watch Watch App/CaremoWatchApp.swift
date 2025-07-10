import SwiftUI
import WatchConnectivity
import WatchKit

@main
struct CaremoWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
