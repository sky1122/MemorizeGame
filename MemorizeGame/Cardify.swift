//
//  Cardify.swift
//  MemorizeGame
//
//  Created by JingweiWang on 7/7/23.
//

import SwiftUI

struct Cardify: ViewModifier {
    var isFaceUp: Bool
    // content: the view I want to modify
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                content
            } else {
                shape.fill()
            }
        }
    }
    
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 15
        static let lineWidth: CGFloat = 3
    }
}

// expose a short way that other view can call this modifier
extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
