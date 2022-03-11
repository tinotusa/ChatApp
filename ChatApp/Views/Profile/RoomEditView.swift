//
//  RoomEditView.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI

struct RoomEditView: View {
    @StateObject var viewModel: RoomEditViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCloseAlert = false
    @State private var showDeleteConfirmation = false
    
    init(room: Room) {
        _viewModel = StateObject(wrappedValue: RoomEditViewModel(room: room))
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Room image")
//                    ImageSelectView(selectedImage: $viewModel.roomImage)
//                        .frame(height: 300)
                    TextField("Name", text: $viewModel.roomName)
                        .textFieldStyle()
                        .labeledView("Name")
                    
                    Toggle(isOn: $viewModel.isPrivate) {
                        Text("Private room")
                    }
                    Toggle(isOn: $viewModel.hasPassword.animation()) {
                        Text("Password locked")
                    }
                    
                    if viewModel.hasPassword {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Password"))
                            .textFieldStyle()
                            .labeledView("Password")

                        SecureField("Password confirmation", text: $viewModel.password, prompt: Text("Password confirmation"))
                            .textFieldStyle()
                            .labeledView("Password confirmation")
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Room Edit")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save") {
                            Task {
                                await viewModel.saveChanges()
                                if !viewModel.errorOccured {
                                    dismiss()
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            if !viewModel.hasMadeChange {
                                dismiss()
                            } else {
                                showCloseAlert = true
                            }
                        }
                    }
                }
            }
        }
        .disabled(viewModel.isLoading)
        .task {
            await viewModel.getImage()
        }
        .alert(
            "Error",
            isPresented: $viewModel.errorOccured,
            presenting: viewModel.alertItem) { item in
                // actions
            } message: { item in
                Text(item.title)
                Text(item.message ?? "N/A")
            }
        .overlay {
            if viewModel.isLoading {
                LoadingCard(text: "Saving changes...")
            }
        }
        .confirmationDialog("Delete", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteRoom() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this room")
        }
        .confirmationDialog("Close", isPresented: $showCloseAlert) {
            Button("OK", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Any changes not saved will be lost")
        }
    }
}

struct RoomEditView_Previews: PreviewProvider {
    static var room = Room.example
    
    static var previews: some View {
        RoomEditView(room: room)
    }
}
