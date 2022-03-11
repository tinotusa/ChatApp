//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Tino on 17/1/22.
//

import Firebase
import SwiftUI
import CryptoKit

@MainActor
final class MessageViewModel: ObservableObject {
    @Published var currentRoom: Room
    @Published var messagesListener: ListenerRegistration? = nil
    @Published var messages = [Message]()
    @Published var messageToSend = ""
    @Published var password = ""
    @Published var roomIsLocked: Bool
    @Published var errorOccured = false
    @Published var alertItem: AlertItem? {
        didSet {
            errorOccured = true
        }
    }
    @Published var hasMoreMessages = false
    private var lastDocument: QueryDocumentSnapshot? = nil
    private let maxMessageQueryCount = 40
    private lazy var auth = Auth.auth()
    private lazy var store = Firestore.firestore()
    private lazy var storage = Storage.storage()
    @Published var selectedImages: [UIImage?] = []
    
    init(room: Room) {
        currentRoom = room
        roomIsLocked = room.hasPassword
    }
    
    var roomCreator: Bool {
        guard let user = auth.currentUser else {
            alertItem = AlertItem(title: "User not logged in")
            return false
        }
        return currentRoom.createdBy == user.uid
    }
    
    func checkPassword() {
        if password.isEmpty {
            alertItem = AlertItem(title: "Invalid password", message: "Password cannot be empty")
            return
        }
        guard let passwordHash = password.hashString else {
            alertItem = AlertItem(title: "Error", message: "Something internal went wrong. Please try again.")
            return
        }
        if passwordHash == currentRoom.passwordHash {
            roomIsLocked = false
            return
        }
        alertItem = AlertItem(title: "Incorrect password")
    }
    
    func sendMessage() async {
        guard let user = auth.currentUser else { return }
        defer {
            selectedImages = []
        }
        if messageToSend.isEmpty { return }
        defer { messageToSend = "" }
        let messagesRef = store
            .collection("messages")
            .document(currentRoom.id)
            .collection("messages")
            .document()
        
        let currentUserRef = store.collection("users").document(user.uid)
        
        do {
            let userSnapshot = try await currentUserRef.getDocument()
            guard let currentUser = try userSnapshot.data(as: User.self) else {
                print("Error in \(#file) \(#function): failed to get the current user from id: \(user.uid)")
                return
            }
            
            // create a message
            let userDetails = UserDetails(
                senderID: currentUser.id,
                name: currentUser.firstName,
                photoURL: currentUser.photoURL
            )
            
            // add images to storage
            let storageRef = storage.reference()
            var paths = [String]()
            for image in selectedImages {
                if image == nil { continue }
                guard let imageData = image!.jpegData(compressionQuality: 0.8) else { return }
                print("image size:", imageData.count)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let path = "images/\(currentUser.id)/\(UUID().uuidString)"
                paths.append(path)
                let imageRef = storageRef.child(path)
                do {
                    _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
                } catch {
                    print("Error in \(#function)\n\(error)")
                }
            }
            
            let message = Message(
                senderDetails: userDetails,
                message: messageToSend,
                attachments: paths
            )
            try messagesRef.setData(from: message)
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    func loadOlderMessages() async {
        guard let lastDocument = lastDocument else {
            hasMoreMessages = false
            return
        }
        let query = store.collection("messages")
            .document(currentRoom.id)
            .collection("messages")
            .order(by: "dateSent", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: maxMessageQueryCount)
        do {
            let snapshot = try await query.getDocuments()
            self.lastDocument = snapshot.documents.last
            hasMoreMessages = self.lastDocument != nil ? true : false

            for document in snapshot.documents {
                if let message = try document.data(as: Message.self) {
                    self.messages.insert(message, at: 0)
                }
            }
        } catch {
            print("Error in \(#function)")
        }
    }
    
    // TODO: set limit to snapshot
    func setMessagesListener() {
        messagesListener = store.collection("messages")
            .document(currentRoom.id)
            .collection("messages")
            .order(by: "dateSent", descending: true)
            .limit(to: maxMessageQueryCount)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error in \(#function): no snapshot found")
                    return
                }
                do {
                    if !snapshot.documents.isEmpty {
                        self.lastDocument = snapshot.documents.last
                        self.hasMoreMessages = true
                    } else {
                        self.hasMoreMessages = false
                    }
                    for i in stride(from: snapshot.documentChanges.count - 1, through: 0, by: -1) {
                        let diff = snapshot.documentChanges[i]
                        if diff.type == .added {
                            if let message = try diff.document.data(as: Message.self) {
                                self.messages.append(message)
                            }
                        }
                        // todo add message deletion
                    }
                } catch {
                    print("Error in \(#function)\n\(error)")
                }
            }
    }
    
    func removeMessagesListener() {
        messagesListener?.remove()
    }
    
}
