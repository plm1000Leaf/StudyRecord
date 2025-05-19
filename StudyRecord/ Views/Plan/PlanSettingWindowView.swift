//
//  PlanSettingWindowView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct PlanSettingWindowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isTapBookSelect = false
    @State private var startPage: String = ""
    @State private var endPage: String = ""
    @State private var isDialogShown = false
    @State private var isRepetition = false
    @Binding var currentMonth: Date
    @Binding var isOn: Bool
    var onClose: () -> Void
    var selectedDate: Date

    var body: some View {
        ZStack{
            
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            windowBase
                VStack(spacing: 24){
                    
                    windowTitle
                    VStack(alignment: .leading){
                        inputLearningContent
                        inputScheduledTime
                    }
                    
                    BasicButton(label: "決定",width: 128, height: 48, fontSize: 24){
                        print("Doneボタンが押されました")
                    }
                    .padding(.bottom, 8)
                    
                }
                .sheet(isPresented: $isTapBookSelect) {
                    BookSelectView()
                }
                .frame(width: 336, height: 520)
                .overlay(
                    Button(action: {
                        onClose() // 親ビューの状態を変更する
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .padding(16)
                            .padding(.top, -8)
                    },
                    alignment: .topLeading // 左上に配置
                )
                
            }
        
    }
}



extension PlanSettingWindowView {
    private var windowTitle: some View {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        let day = calendar.component(.day, from: selectedDate)
        let weekdayIndex = calendar.component(.weekday, from: selectedDate)
        let weekday = calendar.shortWeekdaySymbols[weekdayIndex - 1] // 例: "日", "月", ...

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
        VStack(alignment: .leading){
            Text("学習予定")
                .font(.system(size: 24))
                .padding(.leading, 16)
            
            HStack(spacing:32){
                Button(action: {
                    isTapBookSelect.toggle()
                }){
                    Rectangle()
                        .frame(width: 104, height: 120)
                        .foregroundColor(.mainColor0)
                }
                .padding(.leading, 24)
                
                
                VStack(spacing: 16){
                    HStack(spacing: -8){
                        //startPage
                        InputStudyRange(
                            dailyRecord: DailyRecordManager.shared.fetchOrCreateRecord(for: selectedDate, context: viewContext),
                            type: .start,
                            placeholder: "ページ数",
                            width: 80,
                            height: 40
                        )
                        PullDown()
                    }
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                        .rotationEffect(.degrees(90))
                    HStack(spacing: -8){
                        //endPage
                        InputStudyRange(
                            dailyRecord: DailyRecordManager.shared.fetchOrCreateRecord(for: selectedDate, context: viewContext),
                            type: .end,
                            placeholder: "ページ数",
                            width: 80,
                            height: 40
                        )

                        PullDown()
                    }
                }
                
            }
            .padding(.top, -8)
            .padding(.bottom, 24)
            
        }
    }
    
    
    private var inputScheduledTime: some View {
        VStack(alignment: .leading){
            Text("予定時間")
                .font(.system(size: 24))
                .padding(.leading, 16)
            
            HStack{
                TimeSelectButton()
                    .frame(width: 160 , height: 40)
                    .padding(.bottom, 8)
                
                VStack{                                         ZStack {
                            HStack(spacing: 24){
                                Text("アラーム")
                                    .font(.system(size: 16))
                                Toggle(isOn: $isOn) {
                                    EmptyView() // ラベルを外に出す場合は空
                                }
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                            .padding(.bottom, 64)
                            
                            if isOn {
                                Button(action: {
                                    isDialogShown = true
                                }){
                                    HStack(spacing: 24){
                                        Text("繰り返し")
                                            .frame(width:72, height:8)
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
                                .padding(.leading, -16)
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
            .frame(width: 336, height: 544)
            .cornerRadius(24)
            .overlay(
                CustomRoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                    .foregroundColor(.mainColor0)
                    .frame(width: 336, height: 80)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            )
    }
    
}

