//
//  AITaskService.swift
//  Pushed
//
//  Created by Cassius Villareal on 3/12/25.
//

import Foundation

class AITaskService {
    private let baseURL = "http://localhost:5003"
    
    func generateTask(userId: String, prompt: String) async throws -> Reminder {
        guard let url = URL(string: "\(baseURL)/generate-task") else {
            throw URLError(.badURL)
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON body
        let parameters: [String: Any] = [
            "user_id": userId,
            "prompt": prompt
        ]
        
        // Encode JSON body
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Decode response into a Reminder object
        return try JSONDecoder().decode(Reminder.self, from: data)
    }
}
