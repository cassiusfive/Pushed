//
//  TaskService.swift
//  Pushed
//
//  Created by Cassius Villareal on 3/12/25.
//

import Foundation

class TaskService {
    private let baseURL = "http://localhost:5001"
    
    func fetchTasks(userId: String) async throws -> [Reminder] {
        guard let url = URL(string: "\(baseURL)/tasks/\(userId)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON Response:")
            print(jsonString)
        } else {
            print("Could not convert response data to string")
        }
        
        return try JSONDecoder().decode([Reminder].self, from: data)
    }
    
    func createTask(reminder: Reminder) async throws -> Reminder {
        guard let url = URL(string: "\(baseURL)/tasks") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(reminder)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Reminder.self, from: data)
    }
    
    func updateTask(reminder: Reminder) async throws -> Reminder {
        guard let id = reminder.id,
              let url = URL(string: "\(baseURL)/tasks/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(reminder)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Reminder.self, from: data)
    }
    
    func deleteTask(id: Int) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/tasks/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return true
    }
}
