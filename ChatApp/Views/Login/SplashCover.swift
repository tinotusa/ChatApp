//
//  SplashCover.swift
//  ChatApp
//
//  Created by Tino on 18/1/22.
//

import SwiftUI

struct SplashCover<SplashContent: View>: ViewModifier {
    let timeout: TimeInterval
    let splashContent: () -> SplashContent
    @State private var isActive = true
    
    func body(content: Content) -> some View {
        if isActive {
            splashContent()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                        withAnimation {
                            isActive = false
                        }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func splashCover<Content: View>(
        timeout: TimeInterval = 2,
        content: @escaping () -> Content)
    -> some View {
        modifier(SplashCover(timeout: timeout, splashContent: content))
    }
}
