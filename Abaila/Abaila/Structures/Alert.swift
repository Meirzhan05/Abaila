//
//  Alert.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 7/21/25.
//

import Foundation

struct AlertRequest: Codable {
    let title: String
    let description: String
    let alertType: AlertType
    let location: String
}
