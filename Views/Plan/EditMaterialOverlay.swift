//
//  EditMaterialView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/11/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct EditMaterialOverlay: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var bookName = ""
    @State private var selectedLabel = ""
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var canRegister = false
    @State private var isLabelAddModalPresented = false
    @State private var showDeleteCheckAlert = false
    @Binding var labelList: [String]
    @Binding var isShowing: Bool
    
    let material: Material
    let onDismiss: () -> Void
    
    private let maxCharacters = 12
    
    var body: some View {
        ZStack{
            
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 背景タップでも閉じる
                    onDismiss()
                }
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.baseColor10)
                .frame(width: 344, height: 440)
                .overlay(
                    Button(action: {
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .padding(28)
                            .padding(.top, -8)
                    },
                    alignment: .topLeading
                )
            
            VStack(spacing: 36) {
                imageSelector
                inputFields
            }
            .padding(.top, 40)
            .onChange(of: selectedPhotoItem) { newItem in
                loadSelectedImage(newItem)
            }
            .onAppear {
                // ラベルリストの同期
                syncLabelList()
                initializeFields()
            }
            
        }
        .sheet(isPresented: $isLabelAddModalPresented) {
            LabelAddModal(labels: $labelList, selectedLabel: $selectedLabel)
              .presentationDetents([.fraction(0.15)])
          }
        .alert("教材を削除", isPresented: $showDeleteCheckAlert) {
            
            Button("削除", role: .destructive) {
                deleteMaterial()
            }
            
            Button("キャンセル", role: .cancel) {
            }
            
        } message: {
            Text("\(bookName)を削除しますか?")
        }
        
        }
    }


// MARK: - Image Selector Components
extension EditMaterialOverlay {
    
    private var imageSelector: some View {
        Group {
            if let image = selectedImage {
                selectedImageView(image)
            } else {
                openCameraRollButton
            }
        }

    }
    
    private func selectedImageView(_ image: UIImage) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.notCheckedColor20)
                .frame(width: 144, height: 180)
            
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 96)
                    .cornerRadius(12)
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white).frame(width: 37, height: 37))
                        .offset(y: -8)
                }
            }
            .frame(width: 128, height: 96)
        }
    }

    private var openCameraRollButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.mainColor10)
                    .frame(width: 144, height: 180)
                
                Image(systemName: "photo.badge.plus.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
            }
        }
    }
}

// MARK: - Input Fields Components
extension EditMaterialOverlay {
    
    private var inputFields: some View {
        HStack{
            VStack {
                labelSelector
                nameInputField
            }
            .padding(.top, 16)
            .padding(.leading, 64)
            VStack{
                deleteMaterialButton
                registerMaterialButton
            }
            .padding(.top, 16)
        }
    }
    
    private var labelSelector: some View {
        LabelSelector(
            onAddLabelTapped: {
                isLabelAddModalPresented = true
            },
            labels: Binding(
                get: { labelList },
                set: { newLabels in
                    labelList = newLabels
                    LabelStorage.save(newLabels)
                }
            ),
            selectedLabel: $selectedLabel
        )
        .onChange(of: labelList) { _ in
            validateSelectedLabel()
        }
    }



    
    private var nameInputField: some View {
        ZStack {
            Rectangle()
                .frame(width: 156, height: 64)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            CustomTextEditor(text: $bookName, maxCharacters: maxCharacters)
                .frame(width: 156, height: 56)
                .padding(.top, 8)
                .onChange(of: bookName) { newValue in
                    if newValue.count > maxCharacters {
                        bookName = String(newValue.prefix(maxCharacters))
                    }
                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    canRegister = !trimmed.isEmpty
                }

        }
    }
   
    private var registerMaterialButton: some View {
        Button(action: {
            saveMaterialChanges()
        }) {
            BasicButton(
                label: "変更",
                color:canRegister ? nil : .gray,
                width: 56,
                height: 40
            )
        }
        .padding(.top, 16)
        .padding(.trailing, 48)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(!canRegister)
    }
    
    private var deleteMaterialButton: some View {
        Button(action: {
            showDeleteCheckAlert = true
        }) {
            BasicButton(
                label: "削除",
                color: Color.accentColor1,
                width: 56,
                height: 40
            )
        }
        .padding(.trailing, 48)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(!canRegister)
    }
}

// MARK: - Actions
extension EditMaterialOverlay {
    
    private func loadSelectedImage(_ newItem: PhotosPickerItem?) {
        guard let item = newItem else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = uiImage
                }
            }
        }
    }
    
    private func saveMaterialChanges() {
        let trimmedName = bookName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        material.name = trimmedName
        material.label = selectedLabel.isEmpty ? "未分類" : selectedLabel
        material.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // 新しいラベルの場合はラベルリストに追加
        if !selectedLabel.isEmpty &&
           selectedLabel != "未分類" &&
           !labelList.contains(selectedLabel) {
            labelList.append(selectedLabel)
            labelList.sort()
            LabelStorage.save(labelList)
        }

        do {
            try viewContext.save()
            resetFields()
            // 保存成功後にビューを閉じる
            onDismiss()
            
            print("✅ 教材を更新: \(trimmedName) - \(selectedLabel)")
        } catch {
            print("❌ 教材更新エラー: \(error.localizedDescription)")
        }
    }
    
    private func deleteMaterial() {
        viewContext.delete(material)
        onDismiss()
        do {
            try viewContext.save()
        } catch {
            print("教材削除エラー: \(error.localizedDescription)")
        }
    }
    private func resetFields() {
        bookName = ""
        selectedImage = nil
        selectedPhotoItem = nil
        selectedLabel = ""
    }
    
    private func syncLabelList() {
        let savedLabels = LabelStorage.load()
        if labelList != savedLabels {
            labelList = savedLabels
        }
    }
    
    private func validateSelectedLabel() {
        // 選択中のラベルがリストに存在しない場合はリセット
        if !selectedLabel.isEmpty &&
           selectedLabel != "未分類" &&
           !labelList.contains(selectedLabel) {
            selectedLabel = ""
        }
    }
    
    private func initializeFields() {
        bookName = material.name ?? ""
        selectedLabel = material.label ?? "未分類"
        if let imageData = material.imageData {
            selectedImage = UIImage(data: imageData)
        }
        let trimmed = bookName.trimmingCharacters(in: .whitespacesAndNewlines)
        canRegister = !trimmed.isEmpty
    }
}


