//
//  PlanSettingWindowView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct PlanSettingWindowView: View {
    var body: some View {
        ZStack(alignment: .top){
            windowBase
            VStack(spacing: 24){

                windowTitle
                inputLearningContent
                inputScheduledTime
                BasicButton(label: "決定"){
                    print("Doneボタンが押されました")
                }
                    .frame(width: 128, height: 48)

            }
            .frame(width: 336, height: 520)
            .overlay(
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .padding(8),
                alignment: .topLeading // 左上に配置
            )
            
        }
        
    }
}

#Preview {
    PlanSettingWindowView()
}


extension PlanSettingWindowView {
    private var windowTitle: some View {
        HStack(alignment: .firstTextBaseline) {

            Text("30")
                .font(.system(size: 48))

            Text("(木)")
                .font(.system(size: 24))
                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }

        }
        .padding(.top, -8)




    }
    
    
    private var inputLearningContent: some View {
        VStack(alignment: .leading){
            Text("学習予定")
                .font(.system(size: 24))
            
            HStack(spacing:24){
                
                
                Rectangle()
                    .frame(width: 104, height: 120)
                
                Spacer()
                    .frame(width: 64)
                VStack(spacing: 8){
                    Rectangle()
                        .frame(width: 48, height: 32)
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                        .rotationEffect(.degrees(90))
                    Rectangle()
                        .frame(width: 48, height: 32)
                }
            }
            .padding(.bottom, 32)
            
        }
    }

    
    private var inputScheduledTime: some View {
        VStack(alignment: .leading){
            Text("予定時間")
                .font(.system(size: 24))
            
            HStack(spacing: 40){
                Rectangle()
                    .frame(width: 104, height: 40)
                
                VStack(spacing: 24){
                    HStack {
                        Text("アラーム")
                            .font(.system(size: 16))
                        Rectangle()
                            .frame(width: 48, height: 24)
                    }
                    
                    
                    HStack {
                        Text("繰り返し")
                        Text("なし")
                    }
                    .font(.system(size: 16))
                }
            }
        }
    }
    
    private var windowBase: some View {
        Rectangle()
            .strokeBorder(Color.blue, lineWidth: 1)
            .frame(width: 336, height: 520)
    }
    
}
