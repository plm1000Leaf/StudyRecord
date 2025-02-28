//
//  SwiftUIView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct StudyPlanView: View {
    
    @State private var isTapDate = false
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 56){
                
                planningCalendarView()
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
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
    
    
    private var yearAndMonth: some View {
        HStack(alignment: .bottom){
            Text("2025")
                .font(.system(size: 16))
                .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
            
            Text("1")
                .font(.system(size: 48))
                .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
            
            Image(systemName: "chevron.down")
        }
        .padding(.top, 56)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var planningCalendar: some View {
        Button(action: {
            isTapDate = true
        }){
            Rectangle()
                .frame(width: 336, height: 384)
        }
    }
    
    private var forwardAndBackButton : some View{
        HStack(spacing: 176){
            Circle()
            .frame(width: 48, height: 48)
            Circle()
            .frame(width: 48, height: 48)
        }
    }
    
}
