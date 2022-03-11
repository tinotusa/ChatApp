//
//  Text+boldTitleFont.swift
//  ChatApp
//
//  Created by Tino on 18/1/22.
//

import SwiftUI

extension Text {
    func boldTitleFont() -> some View {
        self
            .font(.title)
            .bold()
    }
}
