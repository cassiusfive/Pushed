//
//  Item.swift
//  Pushed
//
//  Created by Cassius Villareal on 2/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
