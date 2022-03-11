//
//  CreateRoomViewModel.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import CryptoKit
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageSwift
import FirebaseFunctions

final class CreateRoomViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var name = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    
    @Published var isPrivate = false
    @Published var hasPassword = false {
        didSet {
            password = ""
            passwordConfirmation = ""
        }
    }
    @Published var alertItem: AlertItem? = nil
    @Published var roomImage: UIImage? = nil
    
    func createRoom() async {
        let name = name.trim()
        let password = password.trim()
        let passwordConfirmation = passwordConfirmation.trim()
        
        if name.isEmpty {
            alertItem = AlertItem(
                title: "Invalid name",
                message: "Missing the room name"
            )
            return
        }
        if hasPassword {
            if password.isEmpty {
                alertItem = AlertItem(
                    title: "Invalid password",
                    message: "Password cannot be empty if room is password locked"
                )
                return
            }
            if passwordConfirmation.isEmpty {
                alertItem = AlertItem(
                    title: "Invalid password confirmation",
                    message: "Password confirmation cannot be empty"
                )
                return
            }
            if password != passwordConfirmation {
                alertItem = AlertItem(
                    title: "Password mismatch",
                    message: "The passwords do not match"
                )
                return
            }
        }
        withAnimation {
            isLoading = true
        }
        
        defer {
            withAnimation {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        
        guard let user = Auth.auth().currentUser else {
            print("Error in \(#function): User is not logged in")
            return
        }
        let store = Firestore.firestore()
        let roomRef = store.collection("rooms")
            .document(user.uid)
            .collection("roomsCreated")
            .document()
        
        // save image to storage
        let storageRef = Storage.storage().reference()
        let roomImagesRef = storageRef.child("roomImages/\(roomRef.documentID)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if let data = roomImage?.jpegData(compressionQuality: 0.8) {
            do {
                let _ = try await roomImagesRef.putDataAsync(data, metadata: metadata)
            } catch {
                print(error)
            }
        } else {
            print("Error in \(#function): No image data to upload")
        }
        
        // add room collection
        var hashString = ""
        if hasPassword {
            hashString = password.hashString ?? ""
        }
        
        let room = Room(
            id: roomRef.documentID,
            name: name,
            passwordHash: hashString,
            createdBy: user.uid,
            hasPassword: hasPassword,
            isPrivate: isPrivate,
            roomImageURL: roomImage == nil ? "" : roomImagesRef.fullPath,
            subscribers: []
        )
        do {
            try roomRef.setData(from: room)
        } catch let error as NSError {
            print(error)
        }
    }
}
