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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .background(Color.mainColor0)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    BasicButton(label: "ボタン") {
        print("ボタンがタップされました")
    }
}
