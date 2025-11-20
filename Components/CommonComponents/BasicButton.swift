//
//  BasicButton.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct BasicButton: View {
    
    let label: String
    var icon: String? = nil
    var colorOpacity:CGFloat? = nil
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var fontSize: CGFloat? = nil
    var imageSize: CGFloat? = nil
    var cornerRadius: CGFloat = 8
//    let action: () -> Void
    
    var body: some View {
            HStack{
                if let name = icon {
                    Image(systemName: name)
                        .font(.system(size:imageSize ?? 16))
                }
                Text(label)
                    .font(.system(size:fontSize ?? 16))
            }
            .frame(width:width, height: height)
            .padding(.vertical, height == nil ? 8 : 0)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .background(Color.mainColor0.opacity(colorOpacity ?? 1))
            .cornerRadius(8)
        }
    }


#Preview {
    BasicButton(label: "ボタン")
}
