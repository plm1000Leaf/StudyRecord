

//
//  CheckView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/19.
//

import SwiftUI
import CoreData

struct BeforeCheckView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    @State private var userInput: String = ""
    @State private var isTapBookSelect = false
    @State private var startPage: String = "-"
    @State private var endPage: String = "-"
    @State private var selectedUnit: String = "ページ"
    @State private var scheduledHour: Int = 12
    @State private var scheduledMinute: Int = 30
    @State private var isDoneStudyState: Bool = false
    @Binding var selectedTabIndex: Int
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    var selectedDate: Date

    // 今日の日付をチェックするための計算プロパティ
    private var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    

    /// 選択された日付を日本語形式で文字列に変換
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        
        Group {
            // 今日の日付で、かつ完了済みの場合のみAfterCheckViewを表示
            if isToday && isDoneStudyState {
                AfterCheckView(
                    isDoneStudy: $isDoneStudyState,
                    selectedTabIndex: $selectedTabIndex,
                    navigateToReview: $navigateToReview,
                    navigateToPlan: $navigateToPlan, selectedDate: selectedDate,
                    dismiss: {}
                )
            } else {
                mainView
            }
        }
        .onAppear {
            loadDataForDate()
        }
        .onChange(of: selectedDate) { _ in
            loadDataForDate()
        }
    }
    
    private func loadDataForDate() {
        recordService.loadRecord(for: selectedDate, context: viewContext)
        isDoneStudyState = recordService.getIsChecked()
    }

}
        
    

    

//#Preview {
//    BeforeCheckView()
//}

extension BeforeCheckView {
    
    private var mainView :some View {
        ZStack{
            VStack(spacing: 24){
                checkViewTitle
                studyMaterial
                todayStudyPlanSetting
                checkStudyRecordButton
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
        }
        .sheet(isPresented: $isTapBookSelect) {
            BookSelectModal { material in
                recordService.updateMaterial(material, context: viewContext)
            }
        }
        
    }
    private var checkViewTitle: some View {
        Text(formattedSelectedDate)
            .font(.system(size: 32))
            .padding(.top, 16)
            .padding(.leading, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var studyMaterial: some View {
        VStack{
            Button(action: {
                isTapBookSelect.toggle()
            }){
                if let material = recordService.getMaterial() {
                    if let imageData = material.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 136, height: 168)
                    } else {
                        ZStack {
                            Rectangle()
                                .frame(width: 136, height: 168)
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
                    ZStack {
                        Rectangle()
                            .frame(width: 136, height: 168)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        style: StrokeStyle(lineWidth: 4, dash: [5, 4])
                                    )
                                    .foregroundColor(Color.mainColor0)
                            )
                        Text("タップして\nテーマを選択")
                            .font(.system(size: 16))
                            .foregroundColor(.baseColor20)
                    }
                }
            }
            Text(recordService.getMaterial()?.name ?? "未設定")
                .font(.system(size: 24))
                .frame(width: 104, height: 104)
        }
        .padding(.bottom, -16)
        
        
    }
    

    private var todayStudyPlanSetting: some View {
        HStack(alignment: .top){
            
            HStack {
                VStack(spacing: 16) {
                    // 開始範囲
                    HStack(spacing: -10) {
                        InputStudyRange(
                            recordService: recordService,
                            type: .start,
                            placeholder: "ページ数",
                            width: 80,
                            height: 40
                        )
                        PullDown(selectedItem: $selectedUnit, recordService: recordService)
                    }
                    
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                    
                    // 終了範囲
                    HStack(spacing: -10) {
                        InputStudyRange(
                            recordService: recordService,
                            type: .end,
                            placeholder: "ページ数",
                            width: 80,
                            height: 40
                        )
                        PullDown(selectedItem: $selectedUnit, recordService: recordService)
                            .foregroundColor(.accentColor1)
                    }
                }
                
                Spacer()
                
                TimeSelectButton(recordService: recordService, confirmedTime: .constant(false))
                                .frame(width: 168, height: 40)
                                .padding(.trailing, 8)
            }
        }
        .padding(.bottom, 32)
        .padding(.leading, 24)
    }
    
    
    private var checkStudyRecordButton: some View {
        
        Button(action: {
            recordService.updateIsChecked(true, context: viewContext)
            isDoneStudyState = true
            print("完了ボタンが押されました")
        }){
            BasicButton(label: "完了", icon: "checkmark", width: 288, height: 80,fontSize: 48,imageSize: 32)
        }
        .disabled(isDoneStudyState || !isToday)
        .padding(.top, -16)
        
    }
}

//#Preview {
//    BeforeCheckView(selectedTabIndex: .constant(1), navigateToReview: .constant(true), navigateToPlan: .constant(true), selectedDate: $selectedDate)
//}
