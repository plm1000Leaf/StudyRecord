//
//  ShereView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/16.
//

import SwiftUI
import CoreData

struct ShareView: View {
    @Binding var isTapShareButton: Bool
    @State private var continuationDays: Int = 0
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40){
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
                continuationResult
                shareButton
            }
        
        }
    }
    
}

extension ShareView{
    
    private var continuationResult: some View {
        VStack{
            Text("継続日数")
                .font(.system(size: 32))
            Text("\(continuationDays)日")
                .font(.system(size: 40))
        }
        .foregroundColor(.white)
    }
    private var screenShot: some View {
        Rectangle()
            .frame(width:312,height:400)
    }
    private var shareButton: some View {
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
    
    // MARK: - Methods
    
    private func loadContinuationDays() {
        continuationDays = recordService.calculateContinuationDays(context: viewContext)
    }
}
//#Preview {
//    ShareView(isTapShareButton: .constant(.true))
//}
