//
//  Event.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var sportType: SportType
    var location: Location
    var date: Date
    var maxParticipants: Int
    var currentParticipants: [String] // User IDs
    var creatorId: String
}
