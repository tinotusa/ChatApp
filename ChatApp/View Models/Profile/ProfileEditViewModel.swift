//
//  ProfileEditViewModel.swift
//  ChatApp
//
//  Created by Tino on 2/2/2022.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseStorageSwift
import FirebaseFunctions
import FirebaseFunctionsSwift

@MainActor
final class ProfileEditViewModel: ObservableObject {
    let user: User
    @Published var firstName: String
    @Published var lastName: String
    @Published var birthday: Date
    @Published var email: String
    @Published var photoURL: String
    @Published var password: String
    @Published var passwordConfirmation: String
    @Published var alertItem: AlertItem?
    @Published var errorOccured = false
    @Published var isLoading = false
    @Binding var profilePicture: UIImage?
    
    private lazy var store = Firestore.firestore()
    private lazy var storage = Storage.storage()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    
    init(user: User, profilePicture: Binding<UIImage?>) {
        self.user = user
        firstName = user.firstName
        lastName = user.lastName
        birthday = user.birthday
        email = user.email
        photoURL = user.photoURL
        password = ""
        passwordConfirmation = ""
        _profilePicture = profilePicture
    }
    
    var hasChanges: Bool {
        return (
            user.firstName != firstName ||
            user.lastName != lastName ||
            user.birthday != birthday ||
            user.email != email ||
            user.photoURL != photoURL
        )
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print("Error in \(#function): Failed to signout\n\(error)")
            alertItem = AlertItem(
                title: error.domain,
                message: error.localizedDescription
            )
            errorOccured = true
        }
    }
    
    private func getRoomIDs() async -> [String] {
        let roomsRef = store.collection("rooms")
            .document(user.id)
            .collection("roomsCreated")
            .limit(to: 10)
        var roomIDs = [String]()
        do {
            let snapshot = try await roomsRef.getDocuments()
            for document in snapshot.documents {
                if let room = try document.data(as: Room.self) {
                    roomIDs.append(room.id)
                }
            }
        } catch {
            print(error)
        }
        return roomIDs
    }
    
    func deleteAccount() async {
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
        do {
            let roomIDs = await getRoomIDs()
            let messagesPaths = roomIDs.map { id in
                "messages/\(id)/messages"
            }
            let roomImagePaths = roomIDs.map { id in
                "roomImages/\(id)"
            }
            try await functions.httpsCallable("deleteAccount").call([
                "id": user.id,
                "roomsPath": "rooms/\(user.id)/roomsCreated",
                "messagesPaths": messagesPaths,
                "roomImagePaths": roomImagePaths,
                "profilePicturePath": user.photoURL
            ])
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.alertItem = AlertItem(
                    title: error.domain,
                    message: error.localizedDescription
                )
                self.errorOccured  = true
            }
        }
    }
    
    func save() async {
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
    
        print("actual save logic here")
        let firstName = firstName.trim()
        let lastName = lastName.trim()
        let email = email.trim()
        let password = password.trim()
        let passwordConfirmation = passwordConfirmation.trim()
        guard let firebaseUser = Auth.auth().currentUser else {
            print("Error in \(#function): User is not logged in")
            return
        }
        let userRef = store.collection("users").document(firebaseUser.uid)
        
        do {
            if !email.isEmpty && email != user.email {
                try await firebaseUser.updateEmail(to: email)
                try await userRef.setData(["email": email], merge: true)
            }
            if !password.isEmpty || password != passwordConfirmation {
                alertItem = AlertItem(
                    title: "Password mismatch",
                    message: "The passwords do not match or password field is empty")
                errorOccured = true
                return
            }
            if !password.isEmpty && password == passwordConfirmation {
                try await firebaseUser.updatePassword(to: password)
            }
            if profilePicture != nil {
                photoURL = "profileImages/\(firebaseUser.uid)"
                let storageRef = storage.reference()
                let userProfileRef = storageRef.child(photoURL)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                guard let data = profilePicture!.jpegData(compressionQuality: 0.8) else { return }
                let _ = try await userProfileRef.putDataAsync(data, metadata: metadata)
            }
            try await userRef.setData([
                "firstName": firstName,
                "lastName": lastName,
                "photoURL": photoURL,
                "birthday": birthday
            ], merge: true)
            
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
            DispatchQueue.main.async {
                self.alertItem = AlertItem(
                    title: "Email or password error",
                    message: error.localizedDescription
                )
                self.errorOccured = true
            }
        }
        
    }
    
}
