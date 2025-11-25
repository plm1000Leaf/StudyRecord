//
//  LabelSelectModal.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/11/25.
//

import SwiftUI

struct LabelAddModal: View{
    @Environment(\.dismiss) private var dismiss
    @State private var newLabel: String = ""
    @State private var isAddingNewLabel: Bool = false
    @Binding var labels: [String]
    @Binding var selectedLabel: String
    
    private let maxLabelLength = 15
    var body: some View {
        VStack{
            addLabelArea
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(.mainColor0)
                .ignoresSafeArea()
        )
    }
}

extension LabelAddModal {

    
    private var addLabelArea: some View {
        HStack(spacing: 16){
            TextField("ラベル名", text: $newLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 256,height: 48)
                .onChange(of: newLabel) { newValue in
                    // 文字数制限
                    if newValue.count > maxLabelLength {
                        newLabel = String(newValue.prefix(maxLabelLength))
                    }
                }
            Button {
                addNewLabel()
                dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.baseColor10)
                    .font(.system(size: 40))
            }
            .disabled(newLabel.isEmpty || labels.contains(newLabel))
        
        }
    }
    
    private func addNewLabel() {
        let trimmedLabel = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedLabel.isEmpty,
              !labels.contains(trimmedLabel),
              trimmedLabel != "未分類" else {
            return
        }
        
        // ラベルリストに追加
        labels.append(trimmedLabel)
        labels.sort() // アルファベット順にソート
        
        // UserDefaultsに保存
        LabelStorage.save(labels)
        
        // 選択状態を更新
        selectedLabel = trimmedLabel
        
        // フィールドをリセット
        newLabel = ""
        isAddingNewLabel = false
        
        print("✅ 新しいラベルを追加: \(trimmedLabel)")
    }
}
    


//#Preview {
//    LabelAddModal()
//}
