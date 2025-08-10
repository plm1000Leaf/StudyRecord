//
//  PlanSettingWindowView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI
import EventKit
import Combine

struct PlanSettingWindowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    
    @StateObject private var recordService = DailyRecordService.shared
    
    @State private var selectedMaterial: Material? = nil
    @State private var isTapBookSelect = false
    @State private var startPage: String = ""
    @State private var endPage: String = ""
    @State private var isDialogShown = false
    @State private var isRepetition = false
    @State private var timeConfirmed = false
    @Binding var currentMonth: Date
    @Binding var isOn: Bool
    
    var onClose: () -> Void
    var selectedDate: Date
    
    // データ更新通知用のコールバック
    var onDataUpdate: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            windowBase
            
            VStack(spacing: 28) {
                VStack(alignment: .leading) {
                    inputLearningContent
                    inputScheduledTime
                }
                .padding(.top, 16)

                
                BasicButton(label: "決定", width: 128, height: 48, fontSize: 24) {
                    print("決定ボタンが押されました - 日付: \(selectedDate)")
                    
                    // データを保存した後に親に通知
                    onDataUpdate?()
                    onClose()
                }
                .padding(.top, 16)
            }
            .onAppear {
                print("PlanSettingWindow 表示 - 選択日付: \(selectedDate)")
                recordService.loadRecord(for: selectedDate, context: viewContext)
                recordService.debugCurrentState()
                timeConfirmed = recordService.hasScheduledTime()
                checkEventUpdate()
            }
            .onChange(of: selectedDate) { newDate in
                print("PlanSettingWindow 日付変更: \(selectedDate) → \(newDate)")
                recordService.loadRecord(for: newDate, context: viewContext)
                recordService.debugCurrentState()
                timeConfirmed = recordService.hasScheduledTime()
                checkEventUpdate()
            }
            .sheet(isPresented: $isTapBookSelect) {
                BookSelectView { material in
                    recordService.updateMaterial(material, context: viewContext)
                    // 教材更新後に親に通知
                    onDataUpdate?()
                }
            }
            .frame(width: 336, height: 520)
            .overlay(
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .padding(16)
                        .padding(.top, -8)
                },
                alignment: .topLeading
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            checkEventUpdate()
        }
    }

    private var windowTitle: some View {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let day = calendar.component(.day, from: selectedDate)
        let weekdayIndex = calendar.component(.weekday, from: selectedDate)
        let weekday = calendar.shortWeekdaySymbols[weekdayIndex - 1]

        return HStack(alignment: .firstTextBaseline) {
            Text("\(day)")
                .font(.system(size: 48))
            Text("(\(weekday))")
                .font(.system(size: 24))
                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
        }
        .foregroundColor(.baseColor10)
    }
    
    private var inputLearningContent: some View {
        VStack(alignment: .leading) {
            
            HStack(spacing: 32) {
                // 教材表示部分 - 固定サイズのコンテナ
                materialDisplayContainer
                
                VStack(spacing: 16) {
                    HStack(spacing: -8) {
                        // 開始ページ
                        InputStudyRange(
                            recordService: recordService,
                            type: .start,
                            placeholder: "ページ数",
                            width: 80,
                            height: 24
                        )
                        PullDown(recordService: recordService, type: .start)
                    }
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                        .rotationEffect(.degrees(90))
                    HStack(spacing: -8) {
                        // 終了ページ
                        InputStudyRange(
                            recordService: recordService,
                            type: .end,
                            placeholder: "ページ数",
                            width: 80,
                            height: 24
                        )
                        PullDown(recordService: recordService, type: .end)
                    }
                }
            }
            .padding(.leading, 8)
            .padding(.top, 56)
            .padding(.bottom, 40)
        }
    }
    
    private var materialDisplayContainer: some View {
        VStack {
            // 教材画像表示部分（固定サイズ）
            Button(action: {
                isTapBookSelect = true
            }) {
                materialImageView
                    .frame(width: 104, height: 120) // 固定サイズ
                    .cornerRadius(8)
                    .clipped()
            }
            .padding(.top, 32)
            
            // 教材名表示部分（固定サイズ）
            Text(recordService.getMaterial()?.name ?? "未設定")
                .font(.system(size: 16))
                .frame(width: 72, height: 64) // 固定サイズ
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.leading, 24)
        .frame(width: 104 + 24) // コンテナ全体の幅を固定
    }
    
    // 教材画像表示部分
    private var materialImageView: some View {
        Group {
            if let material = recordService.getMaterial() {
                if let imageData = material.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Rectangle()
                            .frame(width: 104, height: 120)
                            .foregroundColor(.gray.opacity(0.3))
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .frame(width: 16)
                                .foregroundColor(.gray10)
                            Text("No Image")
                        }
                    }
                }
            } else {
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.mainColor10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    style: StrokeStyle(lineWidth: 4, dash: [5, 4])
                                )
                                .foregroundColor(Color.mainColor0)
                        )
                    Text("タップで\n教材を選択")
                        .bold()
                        .font(.system(size: 16))
                        .foregroundColor(.baseColor20)
                }
            }
        }
    }
    
    private var inputScheduledTime: some View {
        VStack(alignment: .leading) {
            
            HStack(spacing: 48){
                TimeSelectButton(
                    recordService: recordService, 
                    confirmedTime: $timeConfirmed,
                    onTimeChanged: {
                        // 時間変更時に親に通知
                        onDataUpdate?()
                    }
                )
                    .frame(width: 160, height: 40)
                    .padding(.bottom, 8)
                
                    if timeConfirmed {
                        Button(action: openCalendar) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 72, height: 72)
                                
                                Image(systemName: "calendar")
                                    .foregroundColor(Color.mainColor0)
                                    .font(.system(size: 24))
                                    .bold()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 8)
                        }

            }
            .padding(.leading, 16)
        }
    }
    
    private func openCalendar() {
        let (hour, minute) = recordService.getScheduledTime()
        CalendarEventHelper.shared.requestAccess { granted in
            guard granted else { return }

            let identifier = recordService.getEventIdentifier()
            let materialTitle = recordService.getMaterial()?.name
            let newId = CalendarEventHelper.shared.createOrUpdateEvent(for: selectedDate, hour: Int(hour), minute: Int(minute), title: materialTitle, existingIdentifier: identifier)
            if newId != identifier {
                recordService.updateEventIdentifier(newId, context: viewContext)
            }
            var calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            components.hour = Int(hour)
            components.minute = Int(minute)
            if let targetDate = calendar.date(from: components) {
                let interval = targetDate.timeIntervalSinceReferenceDate
                if let url = URL(string: "calshow:\(interval)") {
                    openURL(url)
                }
        
            }
        }
    }
    
    private func checkEventUpdate() {
        let storedId = recordService.getEventIdentifier()
        var event: EKEvent?
        if let id = storedId {
            event = CalendarEventHelper.shared.fetchEvent(identifier: id)
        }
        // 予定が見つからない場合は日付から検索
        if event == nil {
            event = CalendarEventHelper.shared.findEvent(on: selectedDate)
        }
        guard let foundEvent = event else { return }

        // イベントIDが変更されていた場合は更新
        if foundEvent.eventIdentifier != storedId {
            recordService.updateEventIdentifier(foundEvent.eventIdentifier, context: viewContext)
        }

        let comps = Calendar.current.dateComponents([.hour, .minute], from: foundEvent.startDate)
        let newHour = comps.hour ?? 0
        let newMinute = comps.minute ?? 0
        var didUpdate = false
        let (currentHour, currentMinute) = recordService.getScheduledTime()
        if newHour != currentHour || newMinute != currentMinute {
            recordService.updateScheduledHour(Int16(newHour), context: viewContext)
            recordService.updateScheduledMinute(Int16(newMinute), context: viewContext)

            onDataUpdate?()
        }
    }
    
    private var windowBase: some View {
        Rectangle()
            .fill(Color.baseColor0)
            .frame(width: 336, height: 536)
            .cornerRadius(24)
            .overlay(
                ZStack{
                    CustomRoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        .foregroundColor(.mainColor0)
                        .frame(width: 336, height: 80)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    windowTitle
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            )
    }
}
