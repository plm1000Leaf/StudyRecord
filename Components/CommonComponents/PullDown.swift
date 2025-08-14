//
//  PullDown.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/18.
//


import SwiftUI

struct PullDown: View {
    @Binding var selectedItem: String
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService

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
            recordService.updateStartUnit(newValue, context: viewContext)
            recordService.updateEndUnit(newValue, context: viewContext)
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
        if !studyRange.startUnit.isEmpty {
            selectedItem = studyRange.startUnit
        } else if !studyRange.endUnit.isEmpty {
            selectedItem = studyRange.endUnit
        } else {
            selectedItem = "ページ"
        }
    }
}


//#Preview {
//    PullDown()
//}
