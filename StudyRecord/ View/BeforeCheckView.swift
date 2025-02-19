//
//  CheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI

struct BeforeCheckView: View {
    var body: some View {
        VStack(spacing: 24){
            CheckViewTitle
            
            StudyMaterial

            TodayStudyPlanTitle

            TodayStudyPlanSetting
            
            CheckButton
            
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    BeforeCheckView()
}

extension BeforeCheckView {
    private var CheckViewTitle: some View {
            Text("今日の学習")
                .font(.system(size: 32))
                .padding(.top, 48)
                .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var StudyMaterial: some View {
        VStack(spacing: 16){
            Rectangle()
                .frame(width: 136, height: 168)
            Text("応用情報技術者合格教本")
                .font(.system(size: 24))
                .frame(width: 104, alignment: .leading)
        }
        .padding(.bottom, 16)
    }
    
    private var TodayStudyPlanTitle: some View {
        HStack{
            Text("箇所")
                .font(.system(size: 16))
            Spacer()
                .frame(width: 144)
            Text("予定時間")
                .font(.system(size: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, -8)
    }
    
    private var TodayStudyPlanSetting: some View {
            HStack(alignment: .top){
                VStack(spacing: 8){
                    Rectangle()
                        .frame(width: 48, height: 24)
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                        .rotationEffect(.degrees(90))
                    Rectangle()
                        .frame(width: 48, height: 24)
                }
                
                Spacer()
                    .frame(width: 128)
                VStack {

                    Rectangle()
                        .frame(width: 112 , height: 40)
                    
                }
            }
    }
    
    private var CheckButton: some View {

            Rectangle()
                .frame(width: 288, height: 80)
                .padding(.top, 16)
    }
}
