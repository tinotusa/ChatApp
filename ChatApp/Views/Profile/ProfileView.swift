//
//  ProfileView.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedRoom: Room?
    @EnvironmentObject var session: Session
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        if !viewModel.showEditingScreen {
            profileView
        } else {
            ProfileEditView(
                user: viewModel.user!,
                profilePicture: $viewModel.profileImage,
                isShowingEditScreen: $viewModel.showEditingScreen
            )
                .transition(.move(edge: .top))
        }
    }
}

private extension ProfileView {
    var profileView: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        if viewModel.profileImage != nil {
                            Image(uiImage: viewModel.profileImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .stroke(lineWidth: 3)
                                }
                        }
                        Text(viewModel.user?.fullName ?? "N/A")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 6)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        LabeledText("Name", text: viewModel.user?.fullName ?? "N/A")
                        LabeledText("Email", text: viewModel.user?.email ?? "N/A")
                        LabeledText("Birthday", text: viewModel.user?.birthdayString ?? "N/A")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 6)
                 
                    VStack(alignment: .leading) {
                        Text("Rooms created")
                        ForEach(viewModel.roomsCreated) { room in
                            HStack {
                                Text(room.name)
                                if room.isPrivate {
                                    Image(systemName: "eye.slash")
                                }
                                if room.hasPassword {
                                    Image(systemName: "lock.fill")
                                }
                            }
                            .onTapGesture {
                                selectedRoom = room
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 6)
                }
                .foregroundColor(Color("textFieldColour"))
                .padding(.horizontal)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        HStack {
                            Button("Logout") {
                                showLogoutConfirmation = true

                            }
                            Button("Edit") {
                                withAnimation {
                                    viewModel.showEditingScreen = true
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
            }
        }
        .confirmationDialog(
            "Logout",
            isPresented: $showLogoutConfirmation
        ) {
            Button("Logout", role: .destructive) {
                viewModel.logout()
                session.isLoggedIn = false
            }
        } message: {
            Text("Are you sure you want to logout")
        }
        .sheet(item: $selectedRoom) {
            Task {
                await viewModel.getRoomsCreated()
            }
        } content: { room in
            RoomEditView(room: room)
        }
        .task {
            await viewModel.setUp()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(Session())
            
    }
}
