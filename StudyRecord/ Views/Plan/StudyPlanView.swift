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
    @State private var currentMonth = Date()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack{
                    PlanningCalendar(currentMonth: $currentMonth, isTapDate: $isTapDate, showPopup: $showPopup)
                        .frame(height: geometry.size.height)
                    
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.baseColor0)
                
                if showPopup {
                    MovePeriodPopup(
                        showPopup: $showPopup,
                        items: (1...12).map { "\($0)" },
                        onSelect: { selectedMonth in
                            currentMonth = Calendar.current.date(
                                from: DateComponents(
                                    year: Calendar.current.component(.year, from: currentMonth),
                                    month: selectedMonth
                                )
                            ) ?? currentMonth
                        }
                    )
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
}
#Preview {
    StudyPlanView()
}
