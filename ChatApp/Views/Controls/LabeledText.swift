//
//  LabeledText.swift
//  ChatApp
//
//  Created by Tino on 28/1/2022.
//

import SwiftUI

struct LabeledText: View {
    let label: String
    let text: String
    
    init(_ label: String, text: String) {
        self.label = label
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(text)
        }
    }
}


struct LabeledText_Previews: PreviewProvider {
    static var previews: some View {
        LabeledText(
            "test",
            text: "hello world"
        )
    }
}
