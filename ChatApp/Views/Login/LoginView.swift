//
//  LoginView.swift
//  ChatApp
//
//  Created by Tino on 19/1/22.
//

import SwiftUI
import AuthenticationServices

@MainActor
final class Session: ObservableObject {
    @Published var isLoggedIn = false
}

private enum InputField: Hashable {
    case email, password
}

struct LoginDetails: Codable {
    let email: String
    let password: String
}

// TODO: Show alert for incorrect login details
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @FocusState private var focusedField: InputField?
    @State private var showingAccountRegisterView = false
    @State private var showingPasswordResetScreen = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: Session
    @AppStorage("remeberMe") var rememberMe = false
    @State private var loginDetails: LoginDetails?
    
    let saveURL = "UserLoginDetails"
    
    func saveLoginDetails() {
        if !rememberMe {
            return
        }
        guard let loginDetails = loginDetails else {
            return
        }
        
        // get documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(saveURL)
        do {
            let data = try JSONEncoder().encode(loginDetails)
            try data.write(to: documentsURL, options: [.atomic, .completeFileProtection])
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getLoginDetails() -> LoginDetails? {
        if !rememberMe { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(saveURL)
        do {
            let data = try Data(contentsOf: url)
            let loginDetails = try JSONDecoder().decode(LoginDetails.self, from: data)
            return loginDetails
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    tempLogo

                    Text("Login to your account")
                        .boldTitleFont()

                    Group {
                        emailTextField
                        passwordSecureField
                    }
                    Group {
                        HStack {
                            Toggle("Remember me", isOn: $rememberMe)
                                .toggleStyle(.checkBox)
                            Spacer()
                            Button {
                                showingPasswordResetScreen = true
                            } label: {
                                Text("Forgot password?")
                            }
                        }
                        
                        loginButton

                        divider

                        signInWithAppleButton
                    }
                    footer
                }
                .padding()
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
        .task {
            if rememberMe {
                if let loginDetails = getLoginDetails() {
                    viewModel.email = loginDetails.email
                    viewModel.password = loginDetails.password
                }
            }
        }
        .disabled(viewModel.isLoading)
        .navigationBarHidden(true)
        .overlay {
            if viewModel.isLoading {
                LoadingCard(text: "Logging in...")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(action: selectPreviousField) {
                    Label("Previous", systemImage: "chevron.up")
                }
                Button(action: selectNextField) {
                    Label("Next", systemImage: "chevron.down")
                }
            }
        }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                focusedField = nil
            default: focusedField = nil
            }
        }
        .fullScreenCover(isPresented: $showingAccountRegisterView) {
            AccountRegisterView()
        }
        .fullScreenCover(isPresented: $showingPasswordResetScreen) {
            PasswordResetView()
        }
        .alert(
            "Error",
            isPresented: $viewModel.errorOccured,
            presenting: viewModel.errorDetails) { details in
                //
            } message: { details in
                Text(details.message ?? "Something went wrong.")
            }
//        .splashCover(timeout: 1) {
//            // TODO: add some logo
//            Color.blue.ignoresSafeArea()
//        }
    }
}

// MARK: - Functions
private extension LoginView {
    func selectPreviousField() {
        switch focusedField {
        case .email:
            focusedField = nil
        case .password:
            focusedField = .email
        default: focusedField = nil
        }
    }

    func selectNextField() {
        switch focusedField {
        case .email:
            focusedField = .password
        case .password:
            focusedField = nil
        default: focusedField = nil
        }
    }
}

// MARK: - Views
private extension LoginView {
    var tempLogo: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var emailTextField: some View {
        TextField("", text: $viewModel.email, prompt: Text("Email"))
            .textFieldStyle()
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
    }

    var passwordSecureField: some View {
        SecureField("The user's password for the registered account", text: $viewModel.password, prompt: Text("Password"))
            .textFieldStyle()
            .focused($focusedField, equals: .password)
            .textContentType(.password)
            .submitLabel(.done)
    }

    var loginButton: some View {
        Button {
            if rememberMe {
                loginDetails = LoginDetails(
                    email: viewModel.email,
                    password: viewModel.password
                )
                saveLoginDetails()
            }
            Task {
                await viewModel.login()
                session.isLoggedIn = viewModel.isLoggedIn
            }
        } label: {
            Text("Login")
                .frame(maxWidth: .infinity)
                .customButtonStyle(colour: Color("primaryColour"))
        }
    }

    var divider: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(height: 1)
            Text("or")
            Rectangle()
                .frame(height: 1)
        }
        .foregroundColor(.gray)
    }
    
    var signInWithAppleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                Task {
                    await viewModel.login(authorization: auth)
                    session.isLoggedIn = viewModel.isLoggedIn
                }
            case .failure(let error as NSError):
                print(error)
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 60)
    }
    
    var footer: some View {
        HStack {
            Text("Don't have an account?")
            Button("Sign up") {
                showingAccountRegisterView = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LoginView()
                .environmentObject(Session())
        }
    }
}
