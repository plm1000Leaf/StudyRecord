//
//  PlanSettingWindowView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct PlanSettingWindowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // 独立したサービスではなく、共有サービスを使用
    @StateObject private var recordService = DailyRecordService.shared
    
    @State private var selectedMaterial: Material? = nil
    @State private var isTapBookSelect = false
    @State private var startPage: String = ""
    @State private var endPage: String = ""
    @State private var isDialogShown = false
    @State private var isRepetition = false
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
            
            VStack(spacing: 24) {
                VStack(alignment: .leading) {
                    inputLearningContent
                    inputScheduledTime
                }
                
                BasicButton(label: "決定", width: 128, height: 48, fontSize: 24) {
                    print("決定ボタンが押されました - 日付: \(selectedDate)")
                    
                    // データを保存した後に親に通知
                    onDataUpdate?()
                    onClose()
                }
            }
            .onAppear {
                print("PlanSettingWindow 表示 - 選択日付: \(selectedDate)")
                recordService.loadRecord(for: selectedDate, context: viewContext)
                recordService.debugCurrentState()
            }
            .onChange(of: selectedDate) { newDate in
                print("PlanSettingWindow 日付変更: \(selectedDate) → \(newDate)")
                recordService.loadRecord(for: newDate, context: viewContext)
                recordService.debugCurrentState()
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
                // 教材表示
                if let material = recordService.getMaterial(),
                   let imageData = material.imageData,
                   let uiImage = UIImage(data: imageData) {
                    VStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 104, height: 120)
                            .cornerRadius(8)
                            .clipped()
                            .onTapGesture {
                                isTapBookSelect = true
                            }
                            .padding(.top, 32)
                        Text(material.name ?? "無題")
                            .font(.system(size: 16))
                            .frame(width: 72, height: 64)
                    }
                    .padding(.leading, 24)
                } else {
                    Button(action: {
                        isTapBookSelect.toggle()
                    }) {
                        
                        Rectangle()
                            .frame(width: 104, height: 120)
                            .foregroundColor(.mainColor0)
                        
                    }
                    .padding(.leading, 24)
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: -8) {
                        // 開始ページ
                        InputStudyRange(
                            recordService: recordService,
                            type: .start,
                            placeholder: "ページ数",
                            width: 80,
                            height: 40
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
                            height: 40
                        )
                        PullDown(recordService: recordService, type: .end)
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.top, 56)
            .padding(.bottom, 24)
        }
    }
    
    private var inputScheduledTime: some View {
        VStack(alignment: .leading) {
            
            HStack {
                TimeSelectButton(
                    recordService: recordService,
                    onTimeChanged: {
                        // 時間変更時に親に通知
                        onDataUpdate?()
                    }
                )
                    .frame(width: 160, height: 40)
                    .padding(.bottom, 8)
                
                VStack {
                    ZStack {
                        HStack(spacing: 24) {
                            Text("アラーム")
                                .font(.system(size: 16))
                            Toggle(isOn: $isOn) {
                                EmptyView()
                            }
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding(.bottom, 64)
                        
                        if isOn {
                            Button(action: {
                                isDialogShown = true
                            }) {
                                HStack(spacing: 24) {
                                    Text("繰り返し")
                                        .frame(width: 72, height: 8)
                                        .padding(.leading, 14)
                                        .foregroundColor(.black)
                                    if isRepetition {
                                        Text("あり")
                                            .padding(.leading, 8)
                                    } else {
                                        Text("なし")
                                            .padding(.leading, 8)
                                    }
                                }
                                .font(.system(size: 16))
                            }
                            .padding(.top, 40)
                            .alert(isPresented: $isDialogShown) {
                                if isRepetition {
                                    Alert(
                                        title: Text("毎週木曜日の14時30分\nのアラーム設定を解除します"),
                                        message: Text("本当に解除してもよろしいですか？"),
                                        primaryButton: .destructive(Text("はい")) {
                                            isRepetition = false
                                            print("はいが選択されました")
                                        },
                                        secondaryButton: .cancel(Text("いいえ"))
                                    )
                                } else {
                                    Alert(
                                        title: Text("毎週木曜日の14時30分\nにアラームを鳴らします"),
                                        message: Text("本当に設定してもよろしいですか？"),
                                        primaryButton: .destructive(Text("はい")) {
                                            isRepetition = true
                                            print("はいが選択されました")
                                        },
                                        secondaryButton: .cancel(Text("いいえ"))
                                    )
                                }
                            }
                            .padding(.leading, -24)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
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
