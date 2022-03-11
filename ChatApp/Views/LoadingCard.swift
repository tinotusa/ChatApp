//
//  LoadingCard.swift
//  ChatApp
//
//  Created by Tino on 29/1/2022.
//

import SwiftUI

struct LoadingCard: View {
    var text = "Loading..."
    @State private var shouldAnimate = false
    var slideAndFadeout: AnyTransition {
        .scale.combined(with: .opacity)
    }
    
    struct Constants {
        static let circleHeightRatio = 0.3
        static let circleWidthRatio = 0.35
        static let highlightThickness = 20.0
        static let backgroundThickness = highlightThickness - 5
        static let cardHeightRatio = 0.4
        static let cardWidthRatio = 0.7
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.4), lineWidth: Constants.backgroundThickness)
                        .frame(
                            width: proxy.size.width * Constants.circleWidthRatio,
                            height: proxy.size.height * Constants.circleHeightRatio
                        )
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .stroke(Color("primaryColour"), lineWidth: Constants.highlightThickness)
                        .rotationEffect(.degrees(shouldAnimate ? 360 : 0))
                        .frame(
                            width: proxy.size.width * Constants.circleWidthRatio,
                            height: proxy.size.height * Constants.circleHeightRatio
                        )
                }
                Text(text)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    shouldAnimate = true
                }
            }
            .frame(
                width: proxy.size.width * Constants.cardWidthRatio,
                height: proxy.size.height * Constants.cardHeightRatio
            )
            .background(.white)
            .cornerRadius(15)
            .shadow(
                color: .black.opacity(0.3),
                radius: 5,
                x: 0,
                y: 6
            )
            .frame(
                width: proxy.size.width,
                height: proxy.size.height
            )
        }
        .transition(slideAndFadeout)
    }
}

struct LoadingCard_Previews: PreviewProvider {
    static var previews: some View {
        LoadingCard(text: "Loading...")
    }
}
