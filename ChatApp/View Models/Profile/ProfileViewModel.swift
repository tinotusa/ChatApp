//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageSwift
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var profileImage: UIImage? = nil
    @Published var user: User? = nil
    @Published var showEditingScreen = false
    @Published var roomsCreated = [Room]()
    private lazy var store = Firestore.firestore()
    private lazy var storage = Storage.storage()
    // is this necessary
    // am i even using the isLoggedIn
    init() {
        guard let _ = Auth.auth().currentUser else {
            print("Error in \(#function): User is not logged in")
            return
        }
        isLoggedIn = true
    }
    
    // couldn't make init async so this is used
    // in onAppear or task
    func setUp() async {
        await getUser()
        getProfileImage()
        await getRoomsCreated()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    private func getUser() async {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("Error in \(#function): User is currently not logged in")
            return
        }
        let userRef = store.collection("users").document(firebaseUser.uid)
        
        do {
            let documentSnapshot = try await userRef.getDocument()
            let user = try documentSnapshot.data(as: User.self)
            self.user = user
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    private func getProfileImage() {
        guard let user = user else {
            print("Error in \(#function): User is not logged in")
            return
        }
        let storageRef = storage.reference()
        let defaultPath = "profileImages/defaultProfileImage.jpeg"
        let profileImageRef = storageRef.child(user.photoURL.isEmpty ? defaultPath : user.photoURL)
        profileImageRef.getData(maxSize: 1024 * 1024) { result in
            switch result {
            case .success(let data):
                self.profileImage = UIImage(data: data)
            default:
                print("Error in \(#function): Failed to download profile image data")
                break
            }
        }
    }
    
    func getRoomsCreated() async {
        guard let user = user else {
            print("Error in \(#function): User is not logged in ")
            return
        }
        let query = store.collection("rooms")
            .document(user.id)
            .collection("roomsCreated")
            .limit(to: 10)
        do {
            roomsCreated = []
            let snapshot = try await query.getDocuments()
            for document in snapshot.documents {
                if let room = try document.data(as: Room.self) {
                    self.roomsCreated.append(room)
                }
            }
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
