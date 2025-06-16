//
//  ShereView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/16.
//

import SwiftUI

struct ShareView: View {
    @Binding var isTapShareButton: Bool
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 56){
                Button(action: {
                    isTapShareButton = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(32)
                        
                        .padding(.bottom, -56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                screenShot
                shereButton
            }
        
        }
    }
    
}

extension ShareView{
    private var screenShot: some View {
        Rectangle()
            .frame(width:312,height:400)
    }
    private var shereButton: some View {
        HStack(spacing: 24){
            Rectangle()
                .frame(width:88,height:88)
            Rectangle()
                .frame(width:88,height:88)
            Rectangle()
                .frame(width:88,height:88)
        }
        .padding(.bottom, 40)
    }
}
//#Preview {
//    ShareView(isTapShareButton: $isTapShareButton)
//}
