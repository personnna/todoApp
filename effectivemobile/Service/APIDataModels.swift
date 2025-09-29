//
//  APIDataModels.swift
//  effectivemobile
//
//  Created by ellkaden on 25.09.2025.
//

// APIDataModels.swift
import Foundation

struct TodoResponse: Decodable {
    let todos: [APITodo]
}

struct APITodo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
//    let description: String
}
