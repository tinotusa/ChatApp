//
//  HomeViewModel.swift
//  ChatApp
//
//  Created by Tino on 17/1/22.
//

import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var listener: ListenerRegistration? = nil
    @Published var rooms = [Room]()
    @Published var lastDocument: DocumentSnapshot?
    @Published var hasMoreRooms = false
    private let user: Firebase.User?
    private lazy var store = Firestore.firestore()
    private let maxQueryCount = 10
    init() {
        user = Auth.auth().currentUser
        if user == nil {
            print("Error \(#function): User not logged in")
        }
        
    }
    
    func roomsContaining(searchText: String) -> [Room] {
        let searchText = searchText.lowercased()
        if searchText.isEmpty { return rooms }
        return rooms.filter { room in
            room.name.lowercased().contains(searchText)
        }
    }
    
    // TODO: see if you can send notifications
    func subscribeToRoom(room: Room) async {
        guard let user = Auth.auth().currentUser else {
            print("Error in \(#function): User not logged in")
            return
        }
        
        let roomRef = store.collection("rooms").document(room.id)
        
        do {
            let snapshot = try await roomRef.getDocument()
            
            guard let room = try snapshot.data(as: Room.self) else {
                print("Error in \(#function): Couldn't decode snapshot as Room")
                return
            }
            if room.subscribers.contains(user.uid) {
                try await roomRef.setData(["subscribers": FieldValue.arrayRemove([user.uid])], merge: true)
            } else {
                try await roomRef.setData(["subscribers": FieldValue.arrayUnion([user.uid])], merge: true)
            }
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    func getRooms() async {
        let store = Firestore.firestore()
        let roomsRef = store.collectionGroup("roomsCreated")
            .whereField("isPrivate", isEqualTo: false)
            .order(by: "createdAt")
            .limit(to: maxQueryCount)
        do {
            self.rooms = []
            let querySnapshot = try await roomsRef.getDocuments()
            if !querySnapshot.documents.isEmpty {
                lastDocument = querySnapshot.documents.last!
                hasMoreRooms = true
            } else {
                hasMoreRooms = false
            }
            for document in querySnapshot.documents {
                let room = try document.data(as: Room.self)
                guard let room = room else {
                    print("Error in \(#function) failed to decode Room")
                    return
                }
                self.rooms.append(room)
            }
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    func updateRooms() async {
        guard let lastDocument = lastDocument else {
            print("Error in \(#function): lastDocument is nil")
            return
        }

        let store = Firestore.firestore()
        let roomsRef = store.collectionGroup("roomsCreated")
            .whereField("isPrivate", isEqualTo: false)
            .order(by: "createdAt")
            .start(afterDocument: lastDocument)
            .limit(to: maxQueryCount)
        do {
            let snapshot = try await roomsRef.getDocuments()
            if !snapshot.documents.isEmpty {
                self.lastDocument = snapshot.documents.last!
            } else {
                hasMoreRooms = false
            }
            for document in snapshot.documents {
                let room = try document.data(as: Room.self)
                guard let room = room else {
                    return
                }
                self.rooms.append(room)
            }
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
    
//    func addRoomsListener() {
//        let store = Firestore.firestore()
//        listener = store.collection("rooms")
//            .whereField("isPrivate", isEqualTo: false)
//            .order(by: "createdAt")
//            .limit(to: 10)
//            .addSnapshotListener{ documentSnapshot, error in
//                guard let documentSnapshot = documentSnapshot else {
//                    print("Error \(#function): failed to get document")
//                    return
//                }
//                self.rooms = []
//                for document in documentSnapshot.documents {
//                    do {
//                        guard let room = try document.data(as: Room.self) else {
//                            print("Error \(#function): Failed to decode document as Room")
//                            return
//                        }
//                        self.rooms.append(room)
//                    } catch let error as NSError {
//                        print("Error \(#function) failed to decode Room.\n\(error)")
//                    }
//                }
//            }
//    }
//
//    func removeRoomsListener() {
//        listener?.remove()
//    }
}
