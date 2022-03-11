//
//  SearchBar.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            TextField("Search for room", text: $searchText)
                .submitLabel(.search)
            Image(systemName: "magnifyingglass")
                .font(.title2)
        }
        .padding()
        .background(Color(uiColor: .systemGray5))
        .cornerRadius(15)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant("test search"))
    }
}
