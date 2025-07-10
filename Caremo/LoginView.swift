import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @Binding var showRegister: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                GlassmorphismView {
                    VStack(spacing: 16) {
                        Image("caremo_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                        
                        Text("Login")
                            .font(CaremoTheme.Typography.title)
                            .foregroundColor(CaremoTheme.white)
                        
                        TextField("Email", text: $username)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(CaremoTheme.lightGrayBG.opacity(0.3))
                            .cornerRadius(CaremoTheme.Radius.medium)
                            .foregroundColor(.white)
                        
                        HStack {
                            Toggle("Remember me", isOn: $rememberMe)
                                .toggleStyle(CheckboxToggleStyle())
                                .foregroundColor(CaremoTheme.white)
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                // 🔧 implement reset later
                            }
                            .foregroundColor(CaremoTheme.white.opacity(0.7))
                            .font(CaremoTheme.Typography.caption)
                        }
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Button(action: {
                                isLoading = true
                                AuthService.shared.signin(email: username, password: password) { result in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        switch result {
                                        case .success(let response):
                                            print("✅ Login success for \(response.email)")
                                            session.isLoggedIn = true
                                        case .failure(let error):
                                            print("❌ Login error: \(error.localizedDescription)")
                                            alertMessage = "Login failed: \(error.localizedDescription)"
                                            showAlert = true
                                        }
                                    }
                                }
                            }) {
                                Text("Login").bold()
                            }
                            .buttonStyle(CaremoTheme.ButtonStyle())
                        }
                        
                        Button("Don't have an account? Register") {
                            showRegister = true
                        }
                        .foregroundColor(CaremoTheme.white.opacity(0.8))
                        .font(CaremoTheme.Typography.caption)
                    }
                    .padding()
                    .frame(width: 300)
                }
                .frame(maxHeight: 500)
                
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
