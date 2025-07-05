import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject var authVM = AuthViewModel()
    @State private var showingRegister = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Image("caremo_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 30)

                TextField("Email", text: $authVM.email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                SecureField("Password", text: $authVM.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                if authVM.isLoading {
                    ProgressView()
                }

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    authVM.signin()
                    if authVM.isLoggedIn {
                        session.loginSuccess()
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(8)
                }

                Button(action: {
                    showingRegister = true
                }) {
                    Text("Don’t have an account? Register")
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                }
                .sheet(isPresented: $showingRegister) {
                    RegisterView()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}
