//
//  AccountRegisterView.swift
//  ChatApp
//
//  Created by Tino on 15/1/22.
//

import SwiftUI

private enum InputField {
    case firstName, lastName, email, password, passwordConfimation
}

struct AccountRegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = AccountRegisterViewModel()
    @FocusState private var inputField: InputField?
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Group {
                            TextField("", text: $viewModel.firstName, prompt: Text("First name"))
                                .disableAutocorrection(true)
                                .keyboardType(.namePhonePad)
                                .textContentType(.givenName)
                                .focused($inputField, equals: .firstName)
                                
                            TextField("", text: $viewModel.lastName, prompt: Text("Last name"))
                                .keyboardType(.namePhonePad)
                                .textContentType(.familyName)
                                .focused($inputField, equals: .lastName)
                            
                            TextField("", text: $viewModel.email, prompt: Text("Email"))
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .focused($inputField, equals: .email)
                            
                            SecureField("", text: $viewModel.password, prompt: Text("Password"))
                                .textContentType(.newPassword)
                                .focused($inputField, equals: .password)
                            
                            SecureField("", text: $viewModel.passwordConfirmation, prompt: Text("Confirm password"))
                                .textContentType(.newPassword)
                                .focused($inputField, equals: .passwordConfimation)
                                .submitLabel(.done)
                        }
                        .textFieldStyle()
                        .submitLabel(.next)
                        .onSubmit {
                            switch inputField {
                            case .firstName: inputField = .lastName
                            case .lastName: inputField = .email
                            case .email: inputField = .password
                            case .password: inputField = .passwordConfimation
                            default: inputField = nil
                            }
                        }
                        
                        DatePicker(
                            "Birthday",
                            selection: $viewModel.birthday,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        
                        Button {
                            Task {
                                await viewModel.createUser()
                                if !viewModel.showErrorMessage {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Create account")
                                .frame(maxWidth: .infinity)
                                .customButtonStyle(colour: Color("primaryColour"))
                        }
                        .disabled(!viewModel.allFieldsFilled)
                    }
                    .padding()
                    .frame(width: proxy.size.width)
                    .frame(minHeight: proxy.size.height)
                }
                .alert(isPresented: $viewModel.showErrorMessage) {
                    Alert(
                        title: Text("Something is wrong."),
                        message: Text(viewModel.errorMessage),
                        dismissButton: .cancel()
                    )
                }
                .navigationTitle("Register")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button(action: prevField) {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(!hasPrev)
                        
                        Button(action: nextField) {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(!hasNext)
                    }
                }
            }
        }
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                LoadingCard(text: "Creating account...")
            }
        }
    }
}

private extension AccountRegisterView {
    var hasPrev: Bool {
        switch inputField {
        case .firstName: return false
        default: return true
        }
    }
    
    var hasNext: Bool {
        switch inputField {
        case .passwordConfimation: return false
        default: return true
        }
    }
    
    func nextField() {
        switch inputField {
        case .firstName: inputField = .lastName
        case .lastName: inputField = .email
        case .email: inputField = .password
        case .password: inputField = .passwordConfimation
        default: inputField = nil
        }
    }
    
    func prevField() {
        switch inputField {
        case .lastName: inputField = .firstName
        case .email: inputField = .lastName
        case .password: inputField = .email
        case .passwordConfimation: inputField = .password
        default: inputField = nil
        }
    }
}

struct AccountRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AccountRegisterView()
        }
    }
}
