//
//  ButtonStyles.swift
//  ChatApp
//
//  Created by Tino on 18/1/22.
//

import SwiftUI

struct CustomButtonStyle: ViewModifier {
    let colour: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .font(.title2)
            .background(colour)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func customButtonStyle(colour: Color = .blue) -> some View {
        modifier(CustomButtonStyle(colour: colour))
    }
}

struct ButtonStyles: View {
    let width: Double
    
    var body: some View {
        VStack {
            Button("press me") {
                
            }
            .customButtonStyle() // default colour
        }
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        ButtonStyles(width: 200)
    }
}
