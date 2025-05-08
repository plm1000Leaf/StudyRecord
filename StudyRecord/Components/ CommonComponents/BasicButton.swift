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
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 8
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack{
                if let name = icon {
                    Image(systemName: name)
                }
                Text(label)
                
            }
            .frame(width: width, height: height)
            .padding(.vertical, height == nil ? 8 : 0)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .background(Color.mainColor0)
            .cornerRadius(8)
        }
    }
}

#Preview {
    BasicButton(label: "ボタン") {
        print("ボタンがタップされました")
    }
}
