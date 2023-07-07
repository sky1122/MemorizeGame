//
//  Pie.swift
//  MemorizeGame
//
//  Created by JingweiWang on 7/6/23.
//

import SwiftUI

struct Pie: Shape {
    // animated startAngle and endAngle
    var startAngle: Angle
    var endAngle: Angle
    // let can only get value once, and for this I want people to set the clockwise value when I init it.
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        // draw things in the shape

    
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + CGFloat(cos(startAngle.radians)),
            y: center.y + CGFloat(sin(startAngle.radians))
        )
        
        var p = Path()
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockwise
        )
        
        return p
    }
}
