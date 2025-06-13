//
//  BookSelectView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/21.
//

import SwiftUI
import PhotosUI
import CoreData

struct BookSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isTapAddBook = false
    @State private var text: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedLabel: String = ""
    @State private var isEditingBook = false
    @State private var editingMaterial: Material? = nil
    @State private var isSelectedEditingMaterial = false
    @State private var editSelectedItem: PhotosPickerItem? = nil
    @State private var editingMaterialName: String = ""
    @State private var editingLabelName: String = ""
    @State private var editingLabelKey: String? = nil
    @State private var labelList: [String] = LabelStorage.load()
    @State private var refreshID = UUID()
    private let maxCharacters = 20
    var onMaterialSelect: ((Material) -> Void)? = nil
    
    @FetchRequest(
        entity: Material.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Material.name, ascending: true)]
    ) private var materials: FetchedResults<Material>
    
    var body: some View {
        ZStack {
            ScrollView{
                VStack(spacing: 40){
                    
                    let groupedMaterials = Dictionary(grouping: materials) { $0.label ?? "未分類" }
                    
                    ForEach(groupedMaterials.sorted(by: { $0.key < $1.key }), id: \.key) { label, items in
                        studyMaterialSection(label: label, materials: items)
                    }
                    
                    if isTapAddBook == true {
                        inputBookInformation
 
                    } else {
                        Button(action: {
                            isTapAddBook = true
                        }){
                            bookAddButton
                        }
                    }
                }
                .overlay(
                    Button(action: {
                        dismiss()
                        isSelectedEditingMaterial = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .padding(8)
                    },
                    alignment: .topLeading
                    
                )
                .overlay(
                    Button(action: {
                        isEditingBook.toggle()
                        // 編集モードを終了する時にeditingMaterialをリセット
                        if !isEditingBook {
                            editingMaterial = nil
                            editingLabelKey = nil
                            isSelectedEditingMaterial = false
                        }
                    }) {
                        Text(isEditingBook ? "完了" : "編集")
                            .font(.system(size: 20))
                            .padding(8)
                            .foregroundColor(.blue)
                    },
                    alignment: .topTrailing
                    
                )
                
                .padding(.horizontal, 20)
            }
            .background(Color.baseColor10)
            

        }
    }

}


extension BookSelectView {

    private var bookAddButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 96, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 4,
                                dash: [5, 4]
                            )
                        )
                        .foregroundColor(Color.mainColor0)
                )
            
            Image(systemName: "plus")
                .foregroundColor(Color.mainColor0)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 80)
        
    }
    
    private func studyMaterialSection(label: String, materials: [Material]) ->some View {
        VStack(spacing: 32) {
            if isEditingBook && editingLabelKey == label {
                TextField("教材名", text: $editingLabelName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 96)
                    .multilineTextAlignment(.center)
                    .onSubmit {
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
                            editingLabelKey = nil
                            refreshID = UUID()
                            print("ラベル名を更新しました: \(editingLabelName)")
                        } catch {
                            print("保存に失敗しました: \(error.localizedDescription)")
                        }
                    }

        } else {
            HStack{
                Text(label ?? "")
                    .padding(.top, 40)
                    .font(.system(size: 32))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        editingLabelKey = label
                        editingLabelName = label
                    }
                if isEditingBook{
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .background(Circle().fill(Color.white))
                        .frame(width: 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, -16)
                        .padding(.top, 40)
                        .onTapGesture {
                            deleteLabel(label)
                        }
                    
                }
            }
        }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 32), count: 3), spacing: 24) {
                ForEach(materials) { material in

            ZStack{
                //BookCard
                VStack {
                    if let imageData = material.imageData, let uiImage = UIImage(data: imageData) {
                        // 編集中の教材かどうかで表示を切り替え
                        if isEditingBook && editingMaterial == material {
                            PhotosPicker(
                                selection: Binding<PhotosPickerItem?>(
                                    get: { editSelectedItem },
                                    set: { newItem in
                                        editSelectedItem = newItem
                                    }
                                ),
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 120)
                                    .clipped()
                                    .overlay(
                                        // 編集中の表示を追加
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundColor(.black)
                                                .opacity(0.3)
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 3)
                                            Image(systemName:"photo.fill")
                                                .frame(width: 32)
                                        }
                                    )
                            }
                        } else {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 120)
                                .clipped()
                                .onTapGesture{
                                    if !isEditingBook {
                                        onMaterialSelect?(material)
                                        dismiss()
                                    }
                                }
                        }
                    } else {
                        Rectangle()
                            .frame(width: 96, height: 120)
                            .foregroundColor(.gray.opacity(0.3))
                            .onTapGesture{
                                if !isEditingBook {
                                    onMaterialSelect?(material)
                                    dismiss()
                                }
                            }
                    }
                    
                    // 教材名の表示・編集
                    if isEditingBook && editingMaterial == material {
                        TextField("教材名", text: $editingMaterialName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 96)
                            .multilineTextAlignment(.center)
                            .onSubmit {
                                material.name = editingMaterialName
                                do {
                                    try viewContext.save()
                                    editingMaterial = nil // 編集完了
                                    print("教材名を更新しました: \(editingMaterialName)")
                                } catch {
                                    print("保存に失敗しました: \(error.localizedDescription)")
                                }
                            }
                    } else {
                        Text(material.name ?? "")
                            .font(.system(size: 16))
                            .frame(width: 72)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 32)
                
                // 編集ボタンの配置
                if isEditingBook {
                    
                let selectEditMaterialIcon = editingMaterial == material ?
                    "trash.circle.fill" :"pencil.circle.fill"
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            
                            if isSelectedEditingMaterial {
                                deleteMaterial(material)
                            } else {
                                editingMaterial = material
                                editingMaterialName = material.name ?? ""
                                isSelectedEditingMaterial = true
                            }
                        }) {
                            Image(systemName:selectEditMaterialIcon)
                                .font(.system(size: 32))
                                .foregroundColor(editingMaterial == material ? .red : .blue)
                                .background(Circle().fill(Color.white))
                        }
                        .offset(x: 8, y: 8)
                    }
                }
            }
            .onChange(of: editSelectedItem) { newItem in
                Task {
                    if let item = newItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let target = editingMaterial {
                        
                        target.imageData = uiImage.jpegData(compressionQuality: 0.8)
                        try? viewContext.save()
                        
                        editSelectedItem = nil
                        editingMaterial = nil // 編集完了
                        
                        isSelectedEditingMaterial = false
                        
                        refreshID = UUID()
                        print("画像を更新しました for \(target.name ?? "NoName")")
                    } else {
                        print("画像の取得または対象Materialが見つかりませんでした")
                    }
                }
            }
            
                }
            }
        }
        .id(refreshID)

    }
    
    private var inputBookInformation: some View {
        
        HStack(spacing:48){
            if let image = selectedImage {
                ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.baseColor20)
                            .frame(width: 144, height: 180)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mainColor0, lineWidth: 4)
                            )
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 128, height: 96)
                            .cornerRadius(12)
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 37, height: 37)
                                    
                                )
                                .offset(y: -8)
                        }
                    }
                    .frame(width: 128, height: 96)
                }
            } else {
                //imageDataを挿入
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.baseColor20)
                            .frame(width: 144, height: 180)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.mainColor0, lineWidth: 4)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "photo.badge.plus.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 40))
                    }
                }
            }
                VStack{
                    //labelを選択
                    LabelSelector(labels: $labelList, selectedLabel: $selectedLabel)
                    //本のnameを入力
                    ZStack{
                        Rectangle()
                            .frame(width: 156, height: 64)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        CustomTextEditor(text: $text, maxCharacters: maxCharacters)
                            .frame(width: 156, height: 56)
                            .padding(.top, 8)
                    }
                    BasicButton(label: "登録", width: 56, height: 40) {
                        let newMaterial = Material(context: viewContext)
                        newMaterial.id = UUID()
                        newMaterial.name = text
                        newMaterial.label = selectedLabel
                        newMaterial.imageData = selectedImage?.jpegData(compressionQuality: 0.8)

                        do {
                            try viewContext.save()
                            isTapAddBook = false
                            // 新規追加後にフィールドをリセット
                            text = ""
                            selectedImage = nil
                            selectedItem = nil
                            selectedLabel = ""
                        } catch {
                            print("保存エラー: \(error.localizedDescription)")
                        }
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Button("全ての教材を削除") {
                        deleteAllMaterials(context: viewContext)
                    }

                    
                }
                
                
            }
        .padding(.top, 40)
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        }
    
    private func deleteMaterial(_ material: Material) {
        viewContext.delete(material)
        do {
            try viewContext.save()
        } catch {
            print("削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func deleteLabel(_ label: String) {
        // ラベルに紐づく教材を確認
        let associatedMaterials = materials.filter { $0.label == label }

        // 紐づいている場合はラベルを空に（または"未分類"などに）
        for material in associatedMaterials {
            material.label = nil
        }

        
        if let index = labelList.firstIndex(of: label) {
            labelList.remove(at: index)
            LabelStorage.save(labelList)
        }


        do {
            try viewContext.save()
            refreshID = UUID()
            print("ラベル「\(label)」を削除しました")
        } catch {
            print("ラベル削除に失敗しました: \(error.localizedDescription)")
        }
    }

    }

func deleteAllMaterials(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Material.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
        try context.save()
        print("すべての Material を削除しました")
    } catch {
        print("削除に失敗しました: \(error.localizedDescription)")
    }
}


#Preview {
    BookSelectView()
}
