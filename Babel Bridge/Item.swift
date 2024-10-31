//
//  Item.swift
//  Babel Bridge
//
//  Created by 邱鑫 on 10/31/24.
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
