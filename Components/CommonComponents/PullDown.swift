//
//  PullDown.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/18.
//


import SwiftUI

struct PullDown: View {
    @State private var selectedItem = "ページ" // 初期値を明示的に設定
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
    var type: StudyRangeType

    let options = ["-", "ページ", "章"]

    var body: some View {
        Picker("選択してください", selection: $selectedItem) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .foregroundColor(.accentColor1)
                    .tag(option)
                    .fixedSize(horizontal: true, vertical: false) // 折り返しを防ぐ

            }
        }
        .onChange(of: selectedItem) { newValue in
            switch type {
            case .start:
                recordService.updateStartUnit(newValue, context: viewContext)
            case .end:
                recordService.updateEndUnit(newValue, context: viewContext)
            }
        }
        .onAppear {
            updateUnitFromService()
        }
        .onChange(of: recordService.currentRecord) { _ in
            updateUnitFromService()
        }
        .pickerStyle(MenuPickerStyle()) // プルダウンメニュー風
        .frame(width: 100) // 必要に応じて幅を調整
        .padding(4)

    }
    
    private func updateUnitFromService() {
        let studyRange = recordService.getStudyRange()
        switch type {
        case .start:
            selectedItem = studyRange.startUnit.isEmpty ? "ページ" : studyRange.startUnit
        case .end:
            selectedItem = studyRange.endUnit.isEmpty ? "ページ" : studyRange.endUnit
        }
    }
}


//#Preview {
//    PullDown()
//}
