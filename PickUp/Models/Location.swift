//
//  Location.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import Foundation

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var address: String
    var venueName: String?
}
