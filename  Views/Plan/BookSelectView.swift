//
//  BookSelectView.swift
//  StudyRecord
//
//

import SwiftUI
import CoreData

struct BookSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingNewBook = false
    @State private var isEditingMode = false
    @State private var labelList: [String] = LabelStorage.load()
    @State private var refreshID = UUID()
    
    var onMaterialSelect: ((Material) -> Void)? = nil
    
    @FetchRequest(
        entity: Material.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Material.name, ascending: true)]
    ) private var materials: FetchedResults<Material>
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 40) {
                    materialSections
                    addBookSection
                }
                .padding(.horizontal, 20)
            }
            .background(Color.baseColor10)
            .overlay(navigationButtons, alignment: .top)
        }
    }
}

extension BookSelectView {
    
    private var materialSections: some View {
        let groupedMaterials = Dictionary(grouping: materials) { $0.label ?? "未分類" }
        
        return ForEach(groupedMaterials.sorted(by: { $0.key < $1.key }), id: \.key) { label, items in
            MaterialSectionView(
                label: label,
                materials: items,
                isEditingMode: isEditingMode,
                labelList: $labelList,
                refreshID: $refreshID,
                onMaterialSelect: onMaterialSelect,
                onDismiss: { dismiss() }
            )
        }
    }
    
    private var addBookSection: some View {
        Group {
            if isAddingNewBook {
                AddBookView(
                    labelList: $labelList,
                    isShowing: $isAddingNewBook
                )
            } else {
                AddBookButton {
                    isAddingNewBook = true
                }
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            // 閉じるボタン
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .padding(8)
            }
            
            Spacer()
            
            // 編集ボタン
            Button(action: { isEditingMode.toggle() }) {
                Text(isEditingMode ? "完了" : "編集")
                    .font(.system(size: 20))
                    .padding(8)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

#Preview {
    BookSelectView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
