//
//  HomeView.swift
//  ChatApp
//
//  Created by Tino on 15/1/22.
//

import SwiftUI

private enum Tab {
    case home, profile, createRoom
}

struct MainView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: Tab = .home
    @State private var searchText = ""
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
