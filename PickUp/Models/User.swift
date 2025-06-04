//
//  User.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
}
