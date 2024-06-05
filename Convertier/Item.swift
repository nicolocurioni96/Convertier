//
//  Item.swift
//  Convertier
//
//  Created by Nicolò Curioni Dacomat on 05/06/24.
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
