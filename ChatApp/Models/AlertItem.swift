//
//  AlertItem.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI

struct AlertItem: Identifiable {
    var title: String
    var message: String?
    var id = UUID()
    
    var alert: Alert {
        Alert(
            title: Text(title),
            message: message != nil ? Text(message!) : nil,
            dismissButton: .cancel()
        )
    }
}
