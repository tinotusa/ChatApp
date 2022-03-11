//
//  CreateRoomView.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI


struct CreateRoomView: View {
    @StateObject var viewModel = CreateRoomViewModel()
    @Environment(\.dismiss) var dismiss
    
    // TODO: show loading when creating the room
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    TextField("name", text: $viewModel.name, prompt: Text("Room name"))
                        .textFieldStyle()
                    
                    Toggle(isOn: $viewModel.hasPassword.animation()) {
                        Text("Password locked room?")
                    }
                    
                    if viewModel.hasPassword {
                        Group {
                            SecureField("Room password", text: $viewModel.password, prompt: Text("Password"))
                            SecureField("Room password", text: $viewModel.passwordConfirmation, prompt: Text("Password confirmation"))
                        }
                        .textFieldStyle()
                        .textContentType(.newPassword)
                    }
                    
                    Toggle(isOn: $viewModel.isPrivate) {
                        Text("Private room?")
                    }
                    
                    Text("Room image")
//                    ImageSelectView(selectedImages: $viewModel.roomImage)
                        .frame(height: 300)
                    
                    Button {
                        Task {
                            await viewModel.createRoom()
                            dismiss()
                        }
                    } label: {
                        Text("Create room")
                            .frame(maxWidth: .infinity)
                            .customButtonStyle(colour: Color("primaryColour"))
                    }
                }
                .padding(.horizontal)
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    LoadingCard(text: "Creating room...")
                }
            }
            .navigationBarTitle("Create Room")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert(item: $viewModel.alertItem) { item in
                item.alert
            }
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
    }
}
