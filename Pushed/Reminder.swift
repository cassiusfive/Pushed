//
//  Task.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import Foundation

struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date?
    var isCompleted = false
}

extension Reminder {
    static let samples = [
        Reminder(title: "Study for assembly midterm", description: ""),
        Reminder(title: "Put clothes in the laundry", description: "")
    ]
}
