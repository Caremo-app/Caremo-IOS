import Foundation

struct Persona: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    let role: String

    var relay: Bool {
        role == "relay"
    }
}
