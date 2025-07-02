//Add commentMore actions
//  ShereView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/16.
//

import SwiftUI
import UIKit



struct ShareView: View {
    @EnvironmentObject private var snapshotManager: SnapshotManager
    
    @Binding var isTapShareButton: Bool
    let screenshot: UIImage?
    
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
        Group {
            if let screenshot = screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
            }
        }
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
    
    private func snapshot(size: CGSize) -> UIImage {
        // UIHostingController に載せ替え
        let controller = UIHostingController(rootView: self)
        // レンダリング用の View
        let view = controller.view!

        // サイズを指定
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear

        // レンダリング
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
//#Preview {
//    ShareView(isTapShareButton: $isTapShareButton)
//}
