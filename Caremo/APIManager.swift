import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    private let baseURL = "https://api.caremo.id"
    
    // MARK: - POST Request (NO AUTH)
    func postNoAuth(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "No data returned", code: -1)))
            }
        }.resume()
    }
    
    // MARK: - Authenticated POST Request
    func authenticatedPost(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Missing token or URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "No data returned", code: -1)))
            }
        }.resume()
    }
    
    // MARK: - Register (Revised)
    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL + "/api/v1/auth/signup") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL components", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Registration failed with unexpected response", code: -1)))
            }
        }.resume()
    }
    
    // MARK: - Logout
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: baseURL + "/api/v1/auth/logout") else {
            completion(.failure(NSError(domain: "Missing token or URL for logout", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }
    
    // MARK: - Get Family Personas
    func getFamilyPersonas(completion: @escaping (Result<[UserPersona], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: baseURL + "/api/v1/family/list") else {
            completion(.failure(NSError(domain: "Missing token or URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode([UserPersona].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Add Persona
    func addPersona(name: String, email: String, phoneNumber: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "phone_number": phoneNumber,
            "role": role
        ]
        
        authenticatedPost(endpoint: "/api/v1/family/personas", body: body) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
