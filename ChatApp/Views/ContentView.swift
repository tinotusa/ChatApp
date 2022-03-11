//
//  ContentView.swift
//  ChatApp
//
//  Created by Tino on 4/2/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: Session
    
    var body: some View {
        if !session.isLoggedIn {
            LoginView()
        } else {
            MainView()
                .transition(.scale.combined(with: .opacity))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Session())
    }
}
