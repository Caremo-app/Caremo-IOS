import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    // MARK: - General POST Request
    
    func post(endpoint: String, body: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "https://api.caremo.id" + endpoint) else {
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            completion(.success(data))
        }.resume()
    }
    
    // MARK: - Get Family Personas
    
    func getFamilyPersonas(completion: @escaping (Result<[UserPersona], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "https://api.caremo.id/api/v1/family/list") else {
            completion(.failure(NSError(domain: "Missing token or URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    // MARK: - Add Persona with Role
    
    func addPersona(name: String, email: String, phoneNumber: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "phone_number": phoneNumber,
            "role": role
        ]
        
        post(endpoint: "/api/v1/family/personas", body: body) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
