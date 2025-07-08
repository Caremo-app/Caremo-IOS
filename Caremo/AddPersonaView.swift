import SwiftUI

struct AddPersonaView: View {
    @Environment(\.presentationMode) var presentationMode
    var refreshPersonas: () -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var role = "relay" // ✅ default relay
    @State private var isLoading = false
    
    let roles = ["relay", "receiver"]
    
    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .overlay(BlurView(style: .systemUltraThinMaterialDark).opacity(0.4))
                .onTapGesture {
                    hideKeyboard()
                }
            
            GlassmorphismView {
                VStack(spacing: 16) {
                    Text("Add Persona")
                        .font(CaremoTheme.Typography.title)
                        .foregroundColor(.white)
                    
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .keyboardType(.phonePad)
                    
                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized).tag(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button(action: addPersona) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add")
                                .bold()
                        }
                    }
                    .buttonStyle(CaremoTheme.ButtonStyle())
                    .disabled(name.isEmpty || email.isEmpty || phoneNumber.isEmpty)
                }
                .padding()
            }
            .padding()
        }
    }
    
    func addPersona() {
        isLoading = true
        
        APIManager.shared.addPersona(name: name, email: email, phoneNumber: phoneNumber, role: role) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    print("✅ Persona added")
                    refreshPersonas()
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Failed to add persona: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Hide Keyboard Extension

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
