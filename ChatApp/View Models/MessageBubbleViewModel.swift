//
//  MessageBoxViewModel.swift
//  ChatApp
//
//  Created by Tino on 17/1/22.
//

import FirebaseAuth
import Firebase
import SwiftUI

enum ImageLoadError: Error {
    case failed
}

@MainActor
final class MessageBubbleViewModel: ObservableObject {
    private let message: Message
    private lazy var storage = Storage.storage()
    private lazy var auth = Auth.auth()
    @Published var attachments: [UIImage] = [] // change me to an array of media items or something (users can send images, videos, audio, etc.)
    @Published var userID: String
    
    init(message: Message) {
        self.message = message
        userID = Auth.auth().currentUser?.uid ?? "Invalid id"
        Task {
            await getAttachments()
        }
    }
    
    var isSender: Bool {
        return userID == message.senderDetails.senderID
    }
    
    var dateSent: String {
        formatDate(message.dateSent ?? Date())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func getData(storageRef: StorageReference, maxSize: Int64) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            storageRef.getData(maxSize: maxSize) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getAttachments() async {
        guard let attachments = message.attachments else {
            return
        }
        if attachments.isEmpty {
            return
        }
        let storageRef = storage.reference()
        let maxSize: Int64 = 5 * 1024 * 1024
        for path in attachments {
            let imageRef = storageRef.child(path)
            do {
                let data = try await getData(storageRef: imageRef, maxSize: maxSize)
                if let uiImage = UIImage(data: data) {
                    self.attachments.append(uiImage)
                }
            } catch {
                print(error)
            }
        }
    }
}
