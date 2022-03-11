//
//  RoomEditViewModel.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI
import Firebase
import CryptoKit
import FirebaseStorage
import FirebaseStorageSwift
import FirebaseFunctions
import FirebaseFunctionsSwift

@MainActor
final class RoomEditViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var roomName: String
    @Published var hasPassword: Bool {
        didSet {
            password = ""
            passwordConfirmation = ""
        }
    }
    @Published var isPrivate: Bool
    @Published var password: String
    @Published var passwordConfirmation: String
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    private lazy var storage = Storage.storage()
    private lazy var auth = Auth.auth()
    @Published var alertItem: AlertItem?
    @Published var roomImage: UIImage?
    @Published var errorOccured = false {
        didSet {
            errorOccured = true
        }
    }
    var room: Room
    
    init(room: Room) {
        self.room = room
        roomName = room.name
        hasPassword = room.hasPassword
        isPrivate = room.isPrivate
        password = ""
        passwordConfirmation = ""
    }
    
    var hasMadeChange: Bool {
        return (
            roomName != room.name ||
            hasPassword != room.hasPassword ||
            isPrivate != room.isPrivate ||
            !password.isEmpty && password.hashString ?? "" != room.passwordHash
        )
    }
    
    func deleteRoom() async -> Bool {
        withAnimation {
            isLoading = true
        }
        defer {
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                }
            }
        }
        guard let user = Auth.auth().currentUser else {
            return false
        }
        do {
            try await functions.httpsCallable("deleteRoom").call([
                "roomPath": "rooms/\(user.uid)/roomsCreated/\(room.id)",
                "messagesPath": "messages/\(room.id)/messages/",
                "id": "\(room.createdBy)",
                "imagePath": "\(room.roomImageURL)"
            ])
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
            DispatchQueue.main.async {
                self.alertItem = AlertItem(
                    title: "Delete Failed",
                    message: error.localizedDescription
                )
            }
            return false
        }
        return true
    }
    
    func getImage() async {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("roomImages/\(room.id)")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                self.roomImage = image
            case .failure(let error as NSError):
                print("Error in \(#function)\n\(error)")
            }
        }
    }
    
    func saveChanges() async {
        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        let password = password.trim()
        let passwordConfirmation = passwordConfirmation.trim()
        
        if hasPassword {
            if password.isEmpty {
                alertItem = AlertItem(
                    title: "Invalid password",
                    message: "Password cannot be empty."
                )
                return
            }
            
            if password != passwordConfirmation {
                alertItem = AlertItem(
                    title: "Password mismatch",
                    message: "Password and password confirmation do not match"
                )
                return
            }
        }
        guard let user = auth.currentUser else {
            alertItem = AlertItem(
                title: "Error",
                message: "User is not logged in"
            )
            return
        }
        
        let store = Firestore.firestore()
        let roomRef = store.collection("rooms")
            .document(user.uid)
            .collection("roomsCreated")
            .document(room.id)
        
        let imagePath = roomImage == nil ? "" : "roomImages/\(room.id)"
        
        let newRoom = Room(
            id: room.id,
            name: roomName,
            passwordHash: hasPassword ? password.hashString ?? "" : "",
            createdBy: room.createdBy,
            hasPassword: hasPassword,
            isPrivate: isPrivate,
            roomImageURL: imagePath,
            subscribers: []
        )
        
        do {
            try roomRef.setData(from: newRoom)
        } catch let error as NSError {
            alertItem = AlertItem(
                title: error.domain,
                message: error.localizedDescription
            )
            return
        }
        if imagePath.isEmpty || roomImage == nil {
            return
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("roomImages/\(room.id)")
        if let imageData = roomImage!.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            do {
                let _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            } catch let error as NSError {
                alertItem = AlertItem(
                    title: error.domain,
                    message: error.localizedDescription
                )
            }
        }
    }
}
