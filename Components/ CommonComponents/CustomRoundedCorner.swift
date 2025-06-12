//
//  CustomRoundedCorner.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/10.
//

import SwiftUI

struct CustomRoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = [.topLeft, .topRight]
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


