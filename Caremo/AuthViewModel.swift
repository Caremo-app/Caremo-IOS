import Foundation
import Combine

class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Signin
    
    func signin() {
        self.isLoading = true
        self.errorMessage = nil
        
        AuthService.shared.signin(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let loginResponse):
                    print("✅ Login success: \(loginResponse.email)")
                    self?.isLoggedIn = true
                case .failure(let error):
                    print("❌ Login failed: \(error.localizedDescription)")
                    self?.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Refresh Token
    
    func refreshToken() {
        self.isLoading = true
        self.errorMessage = nil
        
        AuthService.shared.refreshToken { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let loginResponse):
                    print("✅ Token refreshed: \(loginResponse.access_token.prefix(20))...")
                case .failure(let error):
                    print("❌ Refresh token failed: \(error.localizedDescription)")
                    self?.errorMessage = "Session expired. Please login again."
                    self?.isLoggedIn = false
                }
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        self.isLoading = true
        self.errorMessage = nil
        
        AuthService.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let message):
                    print("✅ Logout success: \(message)")
                    self?.isLoggedIn = false
                case .failure(let error):
                    print("❌ Logout failed: \(error.localizedDescription)")
                    self?.errorMessage = "Logout failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
