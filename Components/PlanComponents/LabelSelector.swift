//
//  LabelSelector.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/13.
//

import SwiftUI

struct LabelSelector: View {
    @State private var newLabel: String = ""
    @State private var isAddingNewLabel: Bool = false
    @State private var isDeleteLabel: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var labelToDelete: String = ""

    var onAddLabelTapped: () -> Void = {}
    
    @Binding var labels: [String]
    @Binding var selectedLabel: String
    
    private let maxLabelLength = 15
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isAddingNewLabel {
                addLabelField
            } else {
                selectLabelField
            }
        }
        .onAppear {
            // ラベル一覧を同期
            syncLabels()
        }
        .alert("ラベルを削除", isPresented: $showDeleteAlert) {
            Button("削除", role: .destructive) {
                deleteLabel(labelToDelete)
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("「\(labelToDelete)」を削除しますか？\nこのラベルに紐づく教材は「未分類」に変更されます。")
        }
    }
}

// MARK: - Private Views
extension LabelSelector {
    
    private var addLabelField: some View {
        HStack(spacing: 8) {
            TextField("ラベル名", text: $newLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
                .onChange(of: newLabel) { newValue in
                    // 文字数制限
                    if newValue.count > maxLabelLength {
                        newLabel = String(newValue.prefix(maxLabelLength))
                    }
                }

            Button(action: addNewLabel) {
                Image(systemName: "checkmark.circle.fill")                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .disabled(newLabel.isEmpty || labels.contains(newLabel))

            Button(action: cancelAddingLabel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
    }
    
    private var selectLabelField: some View {
        Menu {
            // 既存のラベル一覧
            ForEach(labels.sorted(), id: \.self) { label in
                Button(label) {
                    selectedLabel = label
                }
            }
            
            // 「未分類」オプション（ラベルリストに含まれていない場合）
            if !labels.contains("未分類") {
                Button("未分類") {
                    selectedLabel = "未分類"
                }
            }

            Divider()

            // ラベル追加ボタン
            Button(action: {
                isAddingNewLabel = true
                onAddLabelTapped()
            }) {
                Label("ラベルを追加", systemImage: "plus")
            }

            // ラベル削除ボタン（選択中のラベルがある場合のみ）
            if !selectedLabel.isEmpty && selectedLabel != "未分類" && labels.contains(selectedLabel) {
                Button(action: {
                    labelToDelete = selectedLabel
                    showDeleteAlert = true
                }) {
                    Label("「\(selectedLabel)」を削除", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }

        } label: {
            HStack {
                Text(selectedLabel.isEmpty ? "ラベルを選択" : selectedLabel)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
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

// MARK: - Private Methods
extension LabelSelector {
    
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
    
    private func cancelAddingLabel() {
        newLabel = ""
        isAddingNewLabel = false
    }
    
    private func deleteLabel(_ label: String) {
        guard labels.contains(label) else { return }
        
        // ラベルリストから削除
        if let index = labels.firstIndex(of: label) {
            labels.remove(at: index)
            LabelStorage.save(labels)
        }
        
        // 選択中のラベルが削除された場合は空にする
        if selectedLabel == label {
            selectedLabel = ""
        }
        
        print("🗑️ ラベルを削除: \(label)")
    }
    
    private func syncLabels() {
        // UserDefaultsから最新のラベル一覧を取得して同期
        let savedLabels = LabelStorage.load()
        if labels != savedLabels {
            labels = savedLabels.sorted()
            print("🔄 ラベル一覧を同期: \(labels)")
        }
        
        // 選択中のラベルが存在しない場合はリセット
        if !selectedLabel.isEmpty &&
           selectedLabel != "未分類" &&
           !labels.contains(selectedLabel) {
            selectedLabel = ""
        }
    }
}

// MARK: - LabelStorage (改善版)
struct LabelStorage {
    private static let key = "userLabels"
    private static let defaultLabels = ["参考書", "問題集", "教科書"] // デフォルトラベル

    static func load() -> [String] {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        
        // 初回起動時はデフォルトラベルを設定
        if saved.isEmpty {
            save(defaultLabels)
            return defaultLabels.sorted()
        }
        
        return saved.sorted()
    }

    static func save(_ labels: [String]) {
        // 重複を除去してソート
        let uniqueLabels = Array(Set(labels)).sorted()
        UserDefaults.standard.set(uniqueLabels, forKey: key)
        print("💾 ラベルを保存: \(uniqueLabels)")
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
        print("🔄 ラベルストレージをリセット")
    }
    
    static func addLabel(_ label: String) {
        var labels = load()
        if !labels.contains(label) {
            labels.append(label)
            save(labels)
        }
    }
    
    static func removeLabel(_ label: String) {
        var labels = load()
        if let index = labels.firstIndex(of: label) {
            labels.remove(at: index)
            save(labels)
        }
    }
}
