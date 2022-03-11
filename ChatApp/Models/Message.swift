//
//  Message.swift
//  ChatApp
//
//  Created by Tino on 16/1/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Codable, Identifiable {
    var id = UUID().uuidString
    var senderDetails: UserDetails
    var message: String
    var attachments: [String]?
    @ServerTimestamp var dateSent = Date()
}
