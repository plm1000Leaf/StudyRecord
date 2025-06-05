//
//  SwiftUIView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI
import CoreData
struct StudyPlanView: View {
    
    @State private var isTapDate = false
    @State private var showPopup = false
    @State private var text: String = ""
    @State private var currentMonth = Date()
    @State private var isOn = false
    @State private var selectedDate: Date? = nil

    
    var openPlanSettingOnAppear: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                VStack{
                    PlanningCalendar(
                        currentMonth: $currentMonth,
                        isTapDate: $isTapDate,
                        showPopup: $showPopup,
                        selectedDate: $selectedDate
                    )

                    
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.baseColor0)
                .onAppear {
                    if openPlanSettingOnAppear {
                        isTapDate = true
                    }
                }
                
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
 
                if isTapDate, let selectedDate = selectedDate {
                    PlanSettingWindowView(
                       currentMonth: $currentMonth,
                        isOn: $isOn,
                        onClose: {
                            isTapDate = false
                        }, selectedDate: selectedDate
                    )
                    .zIndex(1)
                }
            }
        }
    }
}
//#Preview {
//    StudyPlanView()
//}
