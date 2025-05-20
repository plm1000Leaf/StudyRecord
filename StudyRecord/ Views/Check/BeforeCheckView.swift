//
//  CheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI
import CoreData

struct BeforeCheckView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    @State private var isDoneStudy = false
    @State private var userInput: String = ""
    @Binding var selectedTabIndex: Int
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
//    var selectedDate: Date
    
    var body: some View {
        Group {
            if !isDoneStudy {
                mainView
            } else {
                AfterCheckView(
                    isDoneStudy: $isDoneStudy,
                    selectedTabIndex: $selectedTabIndex,
                    navigateToReview: $navigateToReview,
                    navigateToPlan: $navigateToPlan,
                    dismiss: {}
                )
            }
        }
    }
}
    

//#Preview {
//    BeforeCheckView()
//}

extension BeforeCheckView {
    
    private var mainView :some View {
        ZStack{
            VStack(spacing: 24){
                VStack{
                    checkViewTitle
                    
                    studyMaterial
                }
                VStack{
                    todayStudyPlanTitle
                    
                    todayStudyPlanSetting
                }
                
                checkButton
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
        }
    }
    private var checkViewTitle: some View {
        Text("今日の学習")
            .font(.system(size: 32))
            .padding(.top, 16)
            .padding(.leading, 56)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var studyMaterial: some View {
        VStack(spacing: 8){
            Rectangle()
                .foregroundColor(.mainColor0)
                .frame(width: 136, height: 168)
            Text("応用情報技術者合格教本")
                .font(.system(size: 24))
                .frame(width: 104, height: 96, alignment: .leading)
        }
        .padding(.bottom, 8)
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
        .padding(.leading, 48)
        .padding(.bottom, 8)
    }
    
    private var todayStudyPlanSetting: some View {
        HStack(alignment: .top){
            VStack(spacing: 16){
                
                HStack(spacing: -24){
//                    InputStudyRange(
//                        dailyRecord: DailyRecordManager.shared.fetchOrCreateRecord(for: selectedDate, context: viewContext),
//                        type: .start,
//                        placeholder: "ページ数",
//                        width: 80,
//                        height: 40
//                    )
//                    PullDown()

                }
                Text("〜")
                    .font(.system(size: 32))
                    .bold()
                    .rotationEffect(.degrees(90))
                HStack(spacing: -24){
//                    InputStudyRange(
//                        dailyRecord: DailyRecordManager.shared.fetchOrCreateRecord(for: selectedDate, context: viewContext),
//                        type: .end,
//                        placeholder: "ページ数",
//                        width: 80,
//                        height: 40
//                    )
//                    PullDown()
//                        .foregroundColor(.accentColor1)

                }
            }
            .padding(.leading, 72)
            
            Spacer()
                .frame(width: 8)

                
                    TimeSelectButton()
                    .frame(width: 168 , height: 40)
                    .padding(.trailing, 16)

                

        }
        .padding(.leading, -56)
    }
    
    private var checkButton: some View {

        BasicButton(label: "Done", icon: "checkmark", width: 288, height: 80,fontSize: 48,imageSize: 32){
                isDoneStudy = true
                print("Doneボタンが押されました")
            }

        }
    }

#Preview {
    BeforeCheckView(selectedTabIndex: .constant(1), navigateToReview: .constant(true), navigateToPlan: .constant(true))
}
