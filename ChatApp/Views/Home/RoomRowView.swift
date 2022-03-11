//
//  MessageRoomView.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI

struct RoomRowView: View {
    let room: Room
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        HStack {
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            Text(room.name)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(Color("textColour"))
        }
        .task {
            room.getRoomImage() { result in
                switch result {
                case .success(let image): uiImage = image
                default: print("failed to get image")
                }
            }
        }
    }
}

struct MessageRowView_Previews: PreviewProvider {
    static let room = Room(
        id: UUID().uuidString,
        name: "A test room",
        createdBy: UUID().uuidString,
        hasPassword: false,
        isPrivate: false,
        roomImageURL: "",
        subscribers: []
    )
    static var previews: some View {
        RoomRowView(room: room)
    }
}
