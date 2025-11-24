//
//  MaterialSectionView.swift
//  StudyRecord
//
//  ラベルごとの教材セクション表示コンポーネント
//

import SwiftUI
import CoreData

struct LabelSeparatedMaterials: View {
    let label: String
    let materials: [Material]
    let isEditingMode: Bool
    @Binding var labelList: [String]
    @Binding var refreshID: UUID
    @Binding var activeEditingLabel: String?
    @Binding var activeEditingMaterialID: UUID?
    let onMaterialSelect: ((Material) -> Void)?
    let onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditingLabel = false
    @State private var editingLabelName = ""
    
    private let maxCharacters = 15
    
    var body: some View {
        VStack(spacing: 24){
            sectionHeader
            materialGrid
        }
        .padding(.bottom, -80)
        .id(refreshID)
        .onChange(of: isEditingMode) { newValue in
            if !newValue {
                isEditingLabel = false
                editingLabelName = ""
                activeEditingLabel = nil
                activeEditingMaterialID = nil
            }
        }
        .onChange(of: activeEditingLabel) { newValue in
            isEditingLabel = (newValue == label)
        }
    }
}

// MARK: - Header Components
extension LabelSeparatedMaterials {
    
    private var sectionHeader: some View {
        HStack {
            if isEditingMode && isEditingLabel {
                labelEditField
            } else {
                labelDisplay
            }
            
            if isEditingMode && label != "未分類"{
                actionLabelButton
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var labelEditField: some View {
        TextField("ラベル名", text: $editingLabelName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 200)
            .font(.system(size: 24))
            .padding(.top, 40)
            .onChange(of: editingLabelName) { newValue in
                if newValue.count > maxCharacters {
                    editingLabelName = String(newValue.prefix(maxCharacters))
                }
            }
            .onSubmit {
                saveLabelEdit()
            }
    }
    
    private var labelDisplay: some View {
        Text(label)
            .padding(.top, 40)
            .font(.system(size: 32))
            .onTapGesture {
                if isEditingMode {
                    startLabelEdit()
                }
            }
    }
    
    private var actionLabelButton: some View {
        Button(action: {
            if isEditingLabel {
                deleteLabel()
            } else {
                startLabelEdit()
            }
        }) {
            Image(systemName: isEditingLabel ? "trash" : "pencil")
                .font(.system(size: 24))
                .foregroundColor(.gray20)
        }
        .padding(.top, 40)
        .padding(.trailing, 32)
    }
    
    private var materialGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 32), count: 3), spacing: 24) {
            ForEach(materials) { material in
                    MaterialCard(
                        material: material,
                        isEditingMode: isEditingMode,
                        onMaterialSelect: onMaterialSelect,
                        onDismiss:  onDismiss,
                        activeEditingLabel: $activeEditingLabel,
                        activeEditingMaterialID: $activeEditingMaterialID
                    )
                
            }
        }
    }
}

// MARK: - Label Edit Actions
extension LabelSeparatedMaterials {
    
    private func startLabelEdit() {
        editingLabelName = label
        isEditingLabel = true
        activeEditingLabel = label
        activeEditingMaterialID = nil
    }
    
    private func saveLabelEdit() {
        for material in materials {
            if material.label == label {
                material.label = editingLabelName
            }
        }
        
        if let index = labelList.firstIndex(of: label),
           !labelList.contains(editingLabelName) {
            labelList[index] = editingLabelName
            labelList.sort()
            LabelStorage.save(labelList)
        }
        
        do {
            try viewContext.save()
            isEditingLabel = false
            activeEditingLabel = nil
            refreshID = UUID()
        } catch {
            print("ラベル保存エラー: \(error.localizedDescription)")
        }
    }
    
    private func deleteLabel() {
        // ラベルに紐づく教材を"未分類"に変更
        for material in materials {
            material.label = "未分類"
        }
        
        // ラベルリストから削除
        if let index = labelList.firstIndex(of: label) {
            labelList.remove(at: index)
            LabelStorage.save(labelList)
        }
        
        do {
            try viewContext.save()
            isEditingLabel = false
            activeEditingLabel = nil
            refreshID = UUID()
        } catch {
            print("ラベル削除エラー: \(error.localizedDescription)")
        }
    }
}
