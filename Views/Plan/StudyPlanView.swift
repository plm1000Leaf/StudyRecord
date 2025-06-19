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
    @State private var calendarRefreshId = UUID() // カレンダー更新用

    var openPlanSettingOnAppear: Bool = false
    var openTomorrowPlan: Bool = false
    
    // 明日の日付を計算
    private var tomorrowDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

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
                    .id(calendarRefreshId) // IDを使ってカレンダーを強制更新
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.baseColor0)
                .onAppear {
                    handleOnAppear()
                }
                .onChange(of: openTomorrowPlan) { newValue in
                    if newValue {
                        openTomorrowPlanWindow()
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
                        },
                        selectedDate: selectedDate,
                        onDataUpdate: {
                            // データ更新時にカレンダーを更新
                            refreshCalendar()
                        }
                    )
                    .zIndex(1)
                    .id("plan-setting-\(selectedDate.timeIntervalSince1970)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleOnAppear() {
        print("StudyPlanView onAppear - openPlanSettingOnAppear: \(openPlanSettingOnAppear), openTomorrowPlan: \(openTomorrowPlan)")
        
        if openPlanSettingOnAppear {
            // 通常の予定設定（今日の日付）
            isTapDate = true
        } else if openTomorrowPlan {
            // 明日の予定を開く
            openTomorrowPlanWindow()
        }
    }
    
    private func openTomorrowPlanWindow() {
        print("明日の予定を開きます: \(tomorrowDate)")
        
        // 明日の日付が属する月にカレンダーを移動
        let tomorrow = tomorrowDate
        currentMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: tomorrow)
        ) ?? tomorrow
        
        // 明日の日付を選択
        selectedDate = tomorrow
        
        // PlanSettingWindowViewを表示
        isTapDate = true
    }
    
    /// カレンダーを強制更新
    private func refreshCalendar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            calendarRefreshId = UUID()
            print("🔄 カレンダーを更新しました")
        }
    }
}
