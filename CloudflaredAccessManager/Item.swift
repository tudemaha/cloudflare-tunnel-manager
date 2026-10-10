//
//  Item.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
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
