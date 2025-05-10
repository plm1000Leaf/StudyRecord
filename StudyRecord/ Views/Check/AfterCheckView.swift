//
//   AfterCheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI

struct AfterCheckView: View {
    @Binding var isDoneStudy: Bool
    @Binding var selectedTabIndex: Int
//    @State private var goToMainTab = false
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    var dismiss: () -> Void
    
    var body: some View {
        afterCheckView
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
//        NavigationStack {
//            afterCheckView
//                .background(
//                    NavigationLink("", isActive: $goToMainTab) {
//                        MainTabView(
//                            selectedTab: $selectedTabIndex,
//                            openDateReview: $navigateToReview,
//                            openPlanSetting: $navigateToPlan
//                        )
//                    }
//                    .hidden()
//                )
//        }
    }
}



extension AfterCheckView {
    
    private var afterCheckView: some View {
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
            BasicButton(label: "振り返る", width: 144, height: 72, fontSize: 24){
                selectedTabIndex = 0
                navigateToReview = true
                dismiss()
                print("振り返るボタンが押されました")
            }
            
            BasicButton(label: "明日の予定", width: 144, height: 72, fontSize: 24){
                selectedTabIndex = 2
                navigateToPlan = true
                dismiss()
                print("明日の予定ボタンが押されました")
            }

            
        }
        
    }

}

#Preview {
    AfterCheckView(isDoneStudy: .constant(true), selectedTabIndex: .constant(1), navigateToReview: .constant(false), navigateToPlan: .constant(false), dismiss: {} )
}
