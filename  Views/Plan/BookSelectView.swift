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
        GeometryReader { geometry in
            ZStack {
                // メインコンテンツ
                VStack(spacing: 0) {
                    // ナビゲーションボタン
                    navigationButtons
                    
                    // スクロール可能なコンテンツ
                    ScrollView {
                        VStack(spacing: 40) {
                            materialSections
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // 下部ボタンのスペースを確保
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.baseColor10)
                
                // AddBookViewのオーバーレイ
                if isAddingNewBook {
                    AddBookView(
                        labelList: Binding(
                            get: { labelList },
                            set: { newLabels in
                                labelList = newLabels
                                LabelStorage.save(newLabels)
                            }
                        ),
                        isShowing: $isAddingNewBook,
                        onDismiss: {
                            // AddBookViewを閉じるだけ
                            isAddingNewBook = false
                        }
                    )
                }
                
                // フローティングボタン（AddBookViewが表示されていない時のみ）
                if !isAddingNewBook {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            addMaterialButtons
                        }
                    }
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                // ラベルリストの同期
                syncLabelList()
            }
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
                labelList: Binding(
                    get: { labelList },
                    set: { newLabels in
                        labelList = newLabels
                        LabelStorage.save(newLabels)
                        refreshID = UUID() // UI更新のため
                    }
                ),
                refreshID: $refreshID,
                onMaterialSelect: onMaterialSelect,
                onDismiss: { dismiss() }
            )
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
        .padding(.bottom, 10)
    }
    
    // 教材追加ボタン
    private var addMaterialButtons: some View {
        Button(action: {
            isAddingNewBook = true
        }) {
            Circle()
                .fill(Color.mainColor0)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Private Methods
    
    private func syncLabelList() {
        let savedLabels = LabelStorage.load()
        if labelList != savedLabels {
            labelList = savedLabels
            refreshID = UUID() // UI更新のため
            print("🔄 BookSelectView: ラベルリストを同期")
        }
    }
}

