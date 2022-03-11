//
//  TextFieldStyles.swift
//  ChatApp
//
//  Created by Tino on 18/1/22.
//

import SwiftUI

struct TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white)
            .foregroundColor(Color("textFieldColour"))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 6)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -1)
    }
}

extension View {
    func textFieldStyle() -> some View {
        modifier(TextFieldStyle())
    }
}


struct TextFieldStyles: View {
    @State private var sampleText = ""
    var body: some View {
        VStack {
            TextField("Email", text: $sampleText)
            SecureField("password", text: $sampleText)
        }
        .padding(.horizontal)
    }
}

struct TextFieldStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldStyles()
    }
}
