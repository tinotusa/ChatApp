//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Tino on 17/1/22.
//

import Firebase
import SwiftUI
import AuthenticationServices

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var rememberMe = false
    @Published var isLoading = false
    @Published var errorOccured = false
    @Published var errorDetails: AlertItem?
    private lazy var auth = Auth.auth()
    private lazy var store = Firestore.firestore()
    
    var allFieldFilled: Bool {
        let email = email.trim()
        let password = password.trim()
       return !email.isEmpty && !password.isEmpty
    }
    
    func login() async {
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
            let _ = try await auth.signIn(withEmail: email, password: password)
            isLoggedIn = true
        } catch let error as NSError {
            // bug in swiftui that ignores the MainActor
            // that's why this is here
            DispatchQueue.main.async { [self] in
                isLoggedIn = false
                errorMessage = error.localizedDescription
            }
            DispatchQueue.main.async {
                self.errorDetails = AlertItem(
                    title: "Login error",
                    message: error.localizedDescription
                )
                self.errorOccured = true
            }
            print(error.localizedDescription)
        }
    }
    
    func login(authorization: ASAuthorization) async {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Error in \(#function): Failed to get apple id credential")
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Error in \(#function): Failed to get apple id token")
            return
        }
        guard let tokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Error in \(#function): Failed to serialize token from apple id token data")
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            accessToken: nil
        )
        do {
            let result = try await auth.signIn(with: credential)
            let userRef = store.collection("users").document(result.user.uid)
            let snapshot = try await userRef.getDocument()
            if !snapshot.exists {
                let user = User(
                    id: result.user.uid,
                    firstName: appleIDCredential.fullName?.givenName ?? "Anonymous",
                    lastName: appleIDCredential.fullName?.familyName ?? "Anonymous",
                    email: appleIDCredential.email ?? "Not set",
                    birthday: Date()
                )
                try userRef.setData(from: user)
            }
            isLoggedIn = true
        } catch let error as NSError {
            print("Error in \(#function)\n\(error)")
        }
    }
}
