//
//  Task.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import Foundation

struct Reminder: Identifiable, Codable {
    var id: Int?
    var user_id: String?
    var title: String
    var description: String
    var dueDate: Date?
    var isCompleted = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case title
        case description
        case isCompleted = "completed"
    }
}

extension Reminder {
    static let samples = [
        Reminder(title: "Study for assembly midterm", description: ""),
        Reminder(title: "Put clothes in the laundry", description: "")
    ]
}
