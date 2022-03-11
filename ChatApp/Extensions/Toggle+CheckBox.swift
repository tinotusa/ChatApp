//
//  Toggle+CheckBox.swift
//  ChatApp
//
//  Created by Tino on 25/1/22.
//

import SwiftUI

struct CheckBoxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .font(.title)
                .foregroundColor(configuration.isOn ? .green : .gray)
            configuration.label
        }
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
            }
        }
    }
}

extension ToggleStyle where Self == CheckBoxStyle {
    static var checkBox: CheckBoxStyle {
        CheckBoxStyle()
    }
}
