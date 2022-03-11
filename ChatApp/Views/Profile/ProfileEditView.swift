//
//  ProfileEditView.swift
//  ChatApp
//
//  Created by Tino on 1/2/2022.
//

import SwiftUI

struct ProfileEditView: View {
    @StateObject var viewModel: ProfileEditViewModel
    @State private var showCloseConfirmation = false
    @Binding var profilePicture: UIImage?
    @EnvironmentObject var session: Session
    @Binding var isShowingEditScreen: Bool
    
    init(user: User, profilePicture: Binding<UIImage?>, isShowingEditScreen: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: ProfileEditViewModel(user: user, profilePicture: profilePicture))
        _profilePicture = profilePicture
        _isShowingEditScreen = isShowingEditScreen
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Profile picture")
//                    ImageSelectView(selectedImage: $profilePicture)
//                        .frame(height: 300)
                    Group {
                        TextField("First name", text: $viewModel.firstName, prompt: Text("First name"))
                            .textFieldStyle()
                            .labeledView("First name")
                            
                        TextField("Last name", text: $viewModel.lastName, prompt: Text("Last name"))
                            .textFieldStyle()
                            .labeledView("Last name")
                        TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                            .textFieldStyle()
                            .labeledView("Email")
                        SecureField("Password", text: $viewModel.password, prompt: Text("New password"))
                            .textFieldStyle()
                            .labeledView("New password")
                        SecureField("Password confirmation", text: $viewModel.passwordConfirmation, prompt: Text("New password confirmation"))
                            .textFieldStyle()
                            .labeledView("New password confirmation")
                    }
                    DatePicker(selection: $viewModel.birthday, displayedComponents: [.date]) {
                        Text("Birthday")
                    }
                    Button {
                        Task {
                            await viewModel.save()
                            if !viewModel.errorOccured {
                                isShowingEditScreen = false
                            }
                        }
                    } label: {
                        Label("Save Changes", systemImage: "square.and.pencil")
                            .frame(maxWidth: .infinity)
                            .customButtonStyle(colour: Color("primaryColour"))
                            
                    }
                    Button {
                        Task {
                            await viewModel.deleteAccount()
                            if !viewModel.errorOccured {
                                viewModel.signOut()
                                session.isLoggedIn = false
                            }
                        }
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .customButtonStyle(colour: .red)
                    }
                }
                .padding()
                .navigationTitle("Edit profile")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            Task {
                                await viewModel.save()
                                if !viewModel.errorOccured {
                                    isShowingEditScreen = false
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            if viewModel.hasChanges {
                                showCloseConfirmation = true
                            } else {
                                isShowingEditScreen = false
                            }
                        }
                    }
                }
            }
        }
        .alert(
            "Error occured",
            isPresented: $viewModel.errorOccured,
            presenting: viewModel.alertItem) { item in
                
            } message: { item in
                Text(item.message ?? "Something went wrong.")
            }
        .confirmationDialog("Close", isPresented: $showCloseConfirmation) {
            Button("Yes", role: .destructive) {
                isShowingEditScreen = false
            }
        } message: {
            Text("Are you sure you want to discard the changes made.")
        }
        .overlay {
            if viewModel.isLoading {
                LoadingCard(text: "Deleting account...")
            }
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(user: User.example, profilePicture: .constant(nil), isShowingEditScreen: .constant(false))
    }
}
