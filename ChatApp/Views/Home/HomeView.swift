//
//  RoomView.swift
//  ChatApp
//
//  Created by Tino on 16/1/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showCreateRoomView = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.rooms.isEmpty {
                    Text("No chat rooms found")
                    Text("Create one yourself 😊")
                } else {
                    ForEach(viewModel.roomsContaining(searchText: searchText)) { room in
                        NavigationLink(destination: MessageView(room: room)) {
                            RoomRowView(room: room)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                Task {
                                    await viewModel.subscribeToRoom(room: room)
                                }
                            } label: {
                                Image(systemName: "bell")
                            }
                            .tint(.green)
                            
                            Button {
                                // todo
                            } label: {
                                Image(systemName: "star")
                            }
                            .tint(.yellow)
                        }
                    }
                    if viewModel.hasMoreRooms {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await viewModel.updateRooms()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Chats")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup {
                    HStack {
                        Button {
                            showCreateRoomView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        Menu {
                            Button {
                                // todo
                            } label: {
                                Label("something", systemImage: "calendar")
                            }
                            Button {
                                // todo
                            } label: {
                                Label("By favourites", systemImage: "star")
                            }
                        } label: {
                            Text("Filter")
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.updateRooms()
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search for a room")
        )
        .task {
            await viewModel.getRooms()
        }
        .sheet(isPresented: $showCreateRoomView) {
            CreateRoomView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
