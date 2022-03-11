//
//  User.swift
//  ChatApp
//
//  Created by Tino on 15/1/22.
//

import SwiftUI

struct UserDetails: Codable {
    var senderID: String
    var name: String
    var photoURL: String
}


enum Status: String, Codable {
    case online, offline
    case doNotDisturb = "Do not disturb"
}

struct User: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var birthday: Date
    var dateCreated = Date() // created "today"
    var email: String
    var status: Status = .online
    var photoURL: String
    
    init(id: String, firstName: String, lastName: String, email: String, birthday: Date) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.id = id
        self.email = email
        photoURL = ""
    }
    
    init() {
        id = ""
        firstName = ""
        lastName = ""
        birthday = Date()
        email = ""
        photoURL = ""
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var birthdayString: String {
        formatDate(birthday)
    }
    
    static var example: User {
        User(
            id: UUID().uuidString,
            firstName: "test name",
            lastName: "Test last",
            email: "test@test.com",
            birthday: Date()
        )
    }
}
