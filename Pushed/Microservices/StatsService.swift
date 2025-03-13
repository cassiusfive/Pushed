//
//  StatsService.swift
//  Pushed
//
//  Created by Cassius Villareal on 3/12/25.
//

import Foundation

class StatsService {
    private let baseURL = "http://localhost:5002"
    
    func fetchUserStats(userId: String) async throws -> [String: Int] {
        guard let url = URL(string: "\(baseURL)/stats/\(userId)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([String: Int].self, from: data)
    }
    
    func getCompletedTaskCount(userId: String) async throws -> Int {
        let stats = try await fetchUserStats(userId: userId)
        return stats["tasks_completed"] ?? 0
    }
}
