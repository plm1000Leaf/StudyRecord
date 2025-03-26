//
//  SwiftUIView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct StudyPlanView: View {
    
    @State private var isTapDate = false
    @State private var showPopup = false
    @State private var text: String = ""
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 56){
                
                PlanningCalendar(isTapDate: $isTapDate,  showPopup: $showPopup)
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
            
            if showPopup {
                MovePeriodPopup(showPopup: $showPopup)
            }
            
            if isTapDate {
                PlanSettingWindowView {
                    isTapDate = false // ×ボタンが押されたら閉じる
                }
                .zIndex(1) // 他のビューより前面に表示
            }
        }
    }
}

#Preview {
    StudyPlanView()
}

extension StudyPlanView {
    



    
}
