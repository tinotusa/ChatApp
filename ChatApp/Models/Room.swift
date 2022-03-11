//
//  Room.swift
//  ChatApp
//
//  Created by Tino on 16/1/22.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseStorageSwift

enum RoomImageError: Error {
    case downloadFailed
}

struct Room: Codable, Identifiable {
    var id: String
    var name: String
    var passwordHash: String?
    var createdBy: String // the room creators user id
    var hasPassword: Bool
    var isPrivate: Bool
    var roomImageURL: String
    var subscribers: [String]
    @ServerTimestamp var createdAt = Date()
    
    func getRoomImage(completion: @escaping (Result<UIImage?, RoomImageError>) -> Void) {
        let storageRef = Storage.storage().reference()
        let roomImageRef = storageRef.child(roomImageURL.isEmpty ? "roomImages/defaultRoomImage.jpeg" : roomImageURL)
        roomImageRef.getData(maxSize: 1024 * 1024) { result in
            switch result {
            case .success(let data):
                let uiImage = UIImage(data: data)
                completion(.success(uiImage))
            case .failure(let error):
                print("Error in \(#function)\n\(error)")
            }
        }
        completion(.failure(.downloadFailed))
    }
    
    static var example: Room {
        Room(
            id: UUID().uuidString,
            name: "room name",
            createdBy: UUID().uuidString,
            hasPassword: false,
            isPrivate: false,
            roomImageURL: "",
            subscribers: []
        )
    }
}
