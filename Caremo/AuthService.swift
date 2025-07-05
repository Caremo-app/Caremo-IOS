import Foundation
import Alamofire

class AuthService {
    
    static let shared = AuthService()
    
    private let baseURL = "https://api.caremo.id/api/v1"
    
    private init() {}
    
    // MARK: - Signin
    
    func signin(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        
        let url = "\(baseURL)/auth/signin"
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding(destination: .queryString),
                   headers: ["Accept": "application/json"])
        .validate()
        .responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let result):
                // Save tokens
                UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
                UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
                UserDefaults.standard.setValue(result.email, forKey: "email")
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Refresh Token
    
    func refreshToken(completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            completion(.failure(NSError(domain: "No refresh token saved", code: 401)))
            return
        }
        
        let url = "\(baseURL)/auth/refresh"
        let params: Parameters = [
            "refresh_token": refreshToken
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding(destination: .queryString),
                   headers: ["Accept": "application/json"])
        .validate()
        .responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let result):
                // Save new tokens
                UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
                UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Logout
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            completion(.failure(NSError(domain: "No refresh token saved", code: 401)))
            return
        }
        
        let url = "\(baseURL)/auth/logout"
        let params: Parameters = [
            "refresh_token": refreshToken
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding(destination: .queryString),
                   headers: ["Accept": "application/json"])
        .validate()
        .responseDecodable(of: LogoutResponse.self) { response in
            switch response.result {
            case .success(let result):
                // Clear saved tokens
                UserDefaults.standard.removeObject(forKey: "access_token")
                UserDefaults.standard.removeObject(forKey: "refresh_token")
                completion(.success(result.message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Response Models

struct LoginResponse: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let email: String
}

struct LogoutResponse: Codable {
    let message: String
}
