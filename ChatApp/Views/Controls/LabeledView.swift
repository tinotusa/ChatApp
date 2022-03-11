//
//  LabeledView.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI

struct LabeledView: ViewModifier {
    
    let label: String
    
    init(label: String) {
        self.label = label
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            content
        }
    }
}

extension View {
    func labeledView(_ label: String) -> some View {
        modifier(LabeledView(label: label))
    }
}
