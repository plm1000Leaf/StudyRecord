//
//  CheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI

struct BeforeCheckView: View {
    @State private var isDoneStudy = false
    @State private var userInput: String = ""
    
    var body: some View {
        Group {
            if isDoneStudy == true {
                AfterCheckView(isDoneStudy: $isDoneStudy)
            } else {
                mainView
            }
        }
    }
}
    

#Preview {
    BeforeCheckView()
}

extension BeforeCheckView {
    
    private var mainView :some View {
        
        VStack(spacing: 24){
            checkViewTitle
            
            studyMaterial
            
            todayStudyPlanTitle
            
            todayStudyPlanSetting
            
            
            checkButton
            
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    private var checkViewTitle: some View {
        Text("今日の学習")
            .font(.system(size: 32))
            .padding(.top, 48)
            .padding(.leading, 56)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var studyMaterial: some View {
        VStack(spacing: 16){
            Rectangle()
                .frame(width: 136, height: 168)
            Text("応用情報技術者合格教本")
                .font(.system(size: 24))
                .frame(width: 104, alignment: .leading)
        }
        .padding(.bottom, 16)
    }
    
    private var todayStudyPlanTitle: some View {
        HStack{

            Text("箇所")
                .font(.system(size: 16))
            Spacer()
                .frame(width: 144)
            Text("予定時間")
                .font(.system(size: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 64)
        .padding(.bottom, 8)
    }
    
    private var todayStudyPlanSetting: some View {
        HStack(alignment: .top){
            VStack(spacing: 8){
                HStack(spacing: -8){
                    InputStudyRange(placeholder: "ページ数")

                    PullDown()

                }
                Text("〜")
                    .font(.system(size: 32))
                    .bold()
                    .rotationEffect(.degrees(90))
                HStack(spacing: -8){
                    InputStudyRange(placeholder: "ページ数")

                    PullDown()

                }
            }
            .padding(.leading, 72)
            
            Spacer()
                .frame(width: 16)

                
                TimeSelectButton()
                    .frame(width: 168 , height: 40)
                    .padding(.trailing, 48)

                

        }
    }
    
    private var checkButton: some View {
        Button(action: {
            isDoneStudy = true
        }){
            BasicButton(label: "Done", icon: "checkmark"){
                print("Doneボタンが押されました")
            }
                .frame(width: 288, height: 80)
                .padding(.top, 16)
        }
    }
}
