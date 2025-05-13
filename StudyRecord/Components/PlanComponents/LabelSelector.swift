//
//  LabelSelector.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/13.
//

import SwiftUI

struct LabelSelector: View {
    @State private var selectedLabel: String = ""
    @State private var newLabel: String = ""
    @State private var labels: [String] = ["英語", "国語", "技術"]
    @State private var isAddingNewLabel: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isAddingNewLabel {
                addLabelField
            } else {
                selectLabelField
            }
        }
    }
}

#Preview {
    LabelSelector()
}

extension LabelSelector {
    
    private var addLabelField: some View {
        HStack(spacing: 8) {
            TextField("ラベル名", text: $newLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)

            Button(action: {
                guard !newLabel.isEmpty, !labels.contains(newLabel) else { return }
                labels.append(newLabel)
                selectedLabel = newLabel
                newLabel = ""
                isAddingNewLabel = false
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }

            Button(action: {
                isAddingNewLabel = false
                newLabel = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
    }
    
    private var selectLabelField: some View {
        
        // ラベル選択メニュー
        Menu {
            ForEach(labels, id: \.self) { label in
                Button(label) {
                    selectedLabel = label
                }
            }

            Divider()

            Button(action: {
                isAddingNewLabel = true
            }) {
                Label("ラベルを追加", systemImage: "plus")
                    .foregroundColor(.blue)
                    
            }
            

        } label: {
            HStack {
                Text(selectedLabel.isEmpty ? "ラベルを選択" : selectedLabel)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5))
            )
            .frame(width: 156)
        }
    }
}
