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
//            Button(action: shareToX) {
                Text("X")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
                    .background(Color.black)
                    .cornerRadius(12)
//            }
            Image(systemName: "camera")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 88, height: 88)
                .background(.purple)
                .cornerRadius(12)
            Image(systemName: "ellipsis")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 88, height: 88)
                .background(.notCheckedColor0)
                .cornerRadius(12)
        }
        .padding(.bottom, 40)
    }
}
//#Preview {
//    ShareView(isTapShareButton: $isTapShareButton)
//}
