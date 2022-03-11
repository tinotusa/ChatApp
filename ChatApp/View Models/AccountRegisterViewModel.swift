//
//  AccountRegisterViewModel.swift
//  ChatApp
//
//  Created by Tino on 17/1/22.
//

import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

@MainActor
final class AccountRegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthday = Date()
    @Published var errorMessage = ""
    @Published var showErrorMessage = false
    @Published var isLoading = false
    
    var allFieldsFilled: Bool {
        let firstName = firstName.trim()
        let lastName = lastName.trim()
        let email = email.trim()
        let password = password.trim()
        let passwordConfirmation = passwordConfirmation.trim()
        return (
            !firstName.isEmpty && !lastName.isEmpty &&
            !email.isEmpty && !password.isEmpty &&
            !passwordConfirmation.isEmpty
        )
    }
    
    @MainActor
    func createUser() async {
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
            if passwordConfirmation != password {
                showErrorMessage = true
                errorMessage = "Password do not match"
                return
            }
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            var user = User()
            user.id = result.user.uid
            user.email = result.user.email ?? email
            user.firstName = firstName
            user.lastName = lastName
            user.birthday = birthday
            user.photoURL = ""
            // create user on database
            let store = Firestore.firestore()
            let userRef = store.collection("users").document(user.id)
            try userRef.setData(from: user)
        } catch let error as NSError {
            print(error)
            errorMessage = error.localizedDescription
            showErrorMessage = true
        }
    }
}
