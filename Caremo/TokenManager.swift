import Foundation

class TokenManager {
    
    static let shared = TokenManager()
    
    private init() {}
    
    /// Get valid access token, auto refresh if expired
    func getValidAccessToken(completion: @escaping (String?) -> Void) {
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            // ✅ For simplicity, assume token is valid. In production, decode exp claim and check expiry.
            completion(token)
        } else {
            // Try refresh token flow
            refreshAccessToken { newToken in
                completion(newToken)
            }
        }
    }
    
    /// Refresh access token using refresh token
    func refreshAccessToken(completion: @escaping (String?) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            print("❌ No refresh token found")
            completion(nil)
            return
        }
        
        guard let url = URL(string: "https://api.caremo.id/api/v1/auth/refresh?refresh_token=\(refreshToken)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Refresh token error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    UserDefaults.standard.set(decoded.access_token, forKey: "access_token")
                    UserDefaults.standard.set(decoded.refresh_token, forKey: "refresh_token")
                    
                    print("✅ Token refreshed successfully")
                    completion(decoded.access_token)
                } catch {
                    print("❌ Failed to decode refresh token response: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }
}
