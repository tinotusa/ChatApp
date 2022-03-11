//
//  MessageBoxView.swift
//  ChatApp
//
//  Created by Tino on 16/1/22.
//

import SwiftUI

struct MessageBubbleView: View {
    var message: Message
    @StateObject var viewModel: MessageBubbleViewModel
    @State private var showDateSent = false
    @State private var showEnlargedImages = false
    init(message: Message) {
        self.message = message
        _viewModel = StateObject(wrappedValue: MessageBubbleViewModel(message: message))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.isSender ? "You" : message.senderDetails.name)
            
            ForEach(viewModel.attachments, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .onTapGesture {
                        showEnlargedImages = true
                    }
            }
            Text("\(message.message)")
                .foregroundColor(.white)
            if showDateSent {
                Text("Sent: \(viewModel.dateSent)")
            }
        }
        .foregroundColor(.secondary)
        .padding()
        .background(viewModel.isSender ? Color("primaryColour") : Color("secondaryColour"))
        .frame(maxWidth: .infinity, alignment: viewModel.isSender ? .trailing : .leading)
        .onTapGesture {
            withAnimation {
                showDateSent.toggle()
            }
        }
    }
}

struct MessageBubbleView_Previews: PreviewProvider {
    static let userDetails = UserDetails(senderID: UUID().uuidString, name: "Some name", photoURL: "")
    
    static var previews: some View {
        MessageBubbleView(message: Message(senderDetails: userDetails, message: "Lorem"))
    }
}
