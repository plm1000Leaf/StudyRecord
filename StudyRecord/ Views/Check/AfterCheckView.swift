//
//   AfterCheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI

struct AfterCheckView: View {
    @Binding var isDoneStudy: Bool
    
    var body: some View {
        VStack(spacing: 80){
            checkViewTitle
            studyDoneText
            continuationDays
            shareButton
            checkButton
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true) 
        .background(Color.baseColor0)
    }
}



extension AfterCheckView {
    private var checkViewTitle: some View {
        Text("今日の学習")
            .font(.system(size: 32))
            .padding(.top, 48)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var studyDoneText: some View {
        Text("学習完了")
            .font(.system(size: 72))
        
    }
    
    private var continuationDays: some View {
        VStack{
            Text("継続日数")
            Text("n日")
        }
        .font(.system(size: 48))
        .padding(.bottom, -64)
        
    }
    
    private var shareButton: some View {
        Image(systemName: "square.and.arrow.up")
            .font(.system(size: 40))
            .frame(maxWidth: .infinity, alignment:
                    .trailing)
        
    }
    
    private var checkButton: some View {
        HStack(spacing: 56){
            Rectangle()
                .frame(width: 144, height: 72)
                .padding(.top, 16)
            Rectangle()
                .frame(width: 144, height: 72)
                .padding(.top, 16)
            
        }
        
    }

}
