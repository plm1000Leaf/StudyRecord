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
    private let maxCharacters = 20
    
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
            Text(label ?? "")
                .padding(.top, 40)
                .font(.system(size: 32))
                .frame(maxWidth: .infinity, alignment: .leading)
            

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 32), count: 3), spacing: 24) {
                ForEach(materials) { material in
                    //BookCard
            ZStack(alignment: .topLeading){
                    VStack {
                        if let imageData = material.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 120)
                                .clipped()
                        } else {
                            Rectangle()
                                .frame(width: 96, height: 120)
                        }
                        Text(material.name ?? "")
                            .font(.system(size: 16))
                            .frame(width: 72)
                    }
                    .padding(.bottom, 32)
                
                if isEditingBook {
                    Button(action: {
                        deleteMaterial(material)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
//                            .foregroundColor(.red)
                            .background(Circle().fill(Color.white))
                    }
                    .offset(x: -8, y: -10)
                }
                }
                }
            }
        }
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
                    LabelSelector(selectedLabel: $selectedLabel)
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

