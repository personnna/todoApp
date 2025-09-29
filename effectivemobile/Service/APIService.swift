//
//  APIService.swift
//  effectivemobile
//
//  Created by ellkaden on 25.09.2025.
//

import Foundation

class APIService {
    func fetchTodos(completion: @escaping (Result<[APITodo], Error>) -> Void) {
        print("APIService: Starting network request...") // <-- ДОБАВЬТЕ ЭТО
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("APIService: Network request failed with error: \(error.localizedDescription)") // <-- ДОБАВЬТЕ ЭТО
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("APIService: No data received.") // <-- ДОБАВЬТЕ ЭТО
                completion(.failure(APIError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(.success(decodedResponse.todos))
                print("APIService: Successfully decoded \(decodedResponse.todos.count) items.") // <-- ДОБАВЬТЕ ЭТО

            } catch {
                completion(.failure(error))
                print("APIService: Decoding failed with error: \(error.localizedDescription)") // <-- ДОБАВЬТЕ ЭТО

            }
        }.resume()
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}
