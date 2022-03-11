//
//  PasswordResetView.swift
//  ChatApp
//
//  Created by Tino on 25/1/22.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class PasswordResetViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var emailSent = false
    @Published var alertItem: AlertItem? {
        didSet {
            errorOccured = true
        }
    }
    @Published var errorOccured = false
    
    func sendResetEmail() async {
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
        let email = email.trim()
        if email.isEmpty {
            alertItem = AlertItem(title: "Error", message: "Invalid email")
            return
        }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            withAnimation(.spring()) {
                self.emailSent = true
            }
        } catch let error as NSError {
            alertItem = AlertItem(
                title: error.domain,
                message: error.localizedDescription
            )
        }
    }
}

struct PasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = PasswordResetViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.emailSent {
                    Group {
                        Text("Email send to: \(viewModel.email)")
                        Image(systemName: "checkmark.square.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                        Button {
                            dismiss()
                        } label: {
                            Text("Back to login")
                                .frame(maxWidth: .infinity)
                                .customButtonStyle(colour: Color("primaryColour"))
                        }
                        
                        
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Text("Enter your account's email.\nAn email with the reset information will be sent to the email provided.")
                        .multilineTextAlignment(.center)
            
                    TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                        .textFieldStyle()
                        .labeledView("Email")

                    Button {
                        Task {
                            await viewModel.sendResetEmail()
                        }
                    } label: {
                        Label("Send", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                            .customButtonStyle(colour: Color("primaryColour"))
                    }
                }
            }
            .padding()
            .disabled(viewModel.isLoading)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingCard(text: "Sending email...")
                }
            }
            .alert(
                "Error",
                isPresented: $viewModel.errorOccured,
                presenting: viewModel.alertItem) { item in
                    // no actions needed
                } message: { item in
                    Text(item.title)
                    Text(item.message ?? "N/A")
                }
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
