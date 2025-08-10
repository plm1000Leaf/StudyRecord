

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
    @State private var scheduledHour: Int = 12
    @State private var scheduledMinute: Int = 30
    @Binding var selectedTabIndex: Int
    @Binding var navigateToReview: Bool
    @Binding var navigateToPlan: Bool
    var selectedDate: Date

    // 今日の日付をチェックするための計算プロパティ
    private var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    // 現在のレコードが完了済みかどうかをチェック
    private var isDoneStudy: Bool {
        recordService.getIsChecked()
    }
    
    var body: some View {
        
        Group {
            // 今日の日付で、かつ学習完了済みの場合のみAfterCheckViewを表示
            if isToday && isDoneStudy {
                AfterCheckView(
                    isDoneStudy: .constant(true),
                    selectedTabIndex: $selectedTabIndex,
                    navigateToReview: $navigateToReview,
                    navigateToPlan: $navigateToPlan,
                    dismiss: {
                    }
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
                checkButton
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.baseColor0)
        }
        .sheet(isPresented: $isTapBookSelect) {
            BookSelectView { material in
                recordService.updateMaterial(material, context: viewContext)
            }
        }
        
    }
    private var checkViewTitle: some View {
        Text("今日の学習")
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
                        Text("タップして\n教材を選択")
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
                        PullDown(recordService: recordService, type: .start)
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
                        PullDown(recordService: recordService, type: .end)
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
    
    
    private var checkButton: some View {
        
        BasicButton(label: "Done", icon: "checkmark", width: 288, height: 80,fontSize: 48,imageSize: 32){
            recordService.updateIsChecked(true, context: viewContext)
            print("Doneボタンが押されました")
        }
        .disabled(isDoneStudy || !isToday)
        .padding(.top, -16)
        
    }
}

//#Preview {
//    BeforeCheckView(selectedTabIndex: .constant(1), navigateToReview: .constant(true), navigateToPlan: .constant(true), selectedDate: $selectedDate)
//}
