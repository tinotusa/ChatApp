//
//  MessageView.swift
//  ChatApp
//
//  Created by Tino on 15/1/22.
//

import SwiftUI
import PhotosUI

struct MessageView: View {
    let room: Room
    @StateObject var viewModel: MessageViewModel
    @Environment(\.dismiss) var dismiss
    @State private var autoScroll = true
    @State private var showMessage = false
    @State private var showImageSelect = false
    
    init(room: Room) {
        self.room = room
        _viewModel = StateObject(wrappedValue: MessageViewModel(room: room))
    }
    
    var body: some View {
        if viewModel.roomIsLocked && !viewModel.roomCreator {
            passwordView
        } else {
            ZStack {
                VStack {
                    messages
                    messageInput
                }
                if showMessage {
                    Text(autoScroll ? "Message scrolling on" : "Message scrolling off")
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            .navigationTitle(room.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        autoScroll.toggle()
                    } label: {
                        Image(systemName: autoScroll ? "pause" : "play")
                    }
                }
            }
            .task {
                viewModel.setMessagesListener()
            }
            .onDisappear {
                viewModel.removeMessagesListener()
            }
            .sheet(isPresented: $showImageSelect) {
                PhotoPickerView(
                    selectedImages: $viewModel.selectedImages,
                    isPresented: $showImageSelect,
                    filters: [.images, .videos],
                    selectionLimit: 0
                )
            }
        }
    }
}

private extension MessageView {
    var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                if viewModel.hasMoreMessages {
                    Button("Load older messages") {
                        Task {
                            await viewModel.loadOlderMessages()
                        }
                    }
                }
                ForEach(viewModel.messages) { message in
                    MessageBubbleView(message: message)
                        .id(message.id)
                }
                .onAppear {
                    proxy.scrollTo(viewModel.messages.last?.id)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if autoScroll {
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id)
                        }
                    }
                }
                .onChange(of: autoScroll) { _ in
                    withAnimation {
                        showMessage = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showMessage = false
                        }
                    }
                }
            }
        }
    }
    
    var messageInput: some View {
        VStack(alignment: .leading) {
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            if let currentImage = image {
                                Image(uiImage: currentImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        guard let index = viewModel.selectedImages.firstIndex(where: { image in
                                            if let image = image {
                                                return image.isEqual(currentImage)
                                            }
                                            return false
                                        }) else {
                                            return
                                        }
                                        _ = withAnimation {
                                            viewModel.selectedImages.remove(at: index)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            HStack {
                Button {
                    showImageSelect = true
                } label: {
                    Image(systemName: "plus")
                }
                TextField("Message", text: $viewModel.messageToSend)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            }
        }
    }
    
    var passwordView: some View {
        VStack {
            Text("Password")
            SecureField("Password", text: $viewModel.password, prompt: Text("Password"))
                .textContentType(.password)
                .onSubmit {
                    viewModel.checkPassword()
                }
            Button("Enter") {
                viewModel.checkPassword()
            }
            Button("Back") {
                dismiss()
            }
        }
        .padding()
        .alert(
            viewModel.alertItem?.title ?? "Error",
            isPresented: $viewModel.errorOccured,
            presenting: viewModel.alertItem
        ) { alertItem in
            
        } message: { alertItem in
            Text(alertItem.message ?? "")
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static let room = Room(
        id: UUID().uuidString,
        name: "test room",
        createdBy: UUID().uuidString,
        hasPassword: true,
        isPrivate: false,
        roomImageURL: "",
        subscribers: []
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                MessageView(room: room)
            }
            NavigationView {
                MessageView(room: room)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
