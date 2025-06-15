//
//  AddBookView.swift
//  StudyRecord
//
//

import SwiftUI
import PhotosUI
import CoreData

struct AddBookView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var bookName = ""
    @State private var selectedLabel = ""
    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @Binding var labelList: [String]
    @Binding var isShowing: Bool
    
    private let maxCharacters = 20
    
    var body: some View {
        HStack(spacing: 48) {
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
        }
    }
}

// MARK: - Image Selector Components
extension AddBookView {
    
    private var imageSelector: some View {
        Group {
            if let image = selectedImage {
                selectedImageView(image)
            } else {
                photoPickerButton
            }
        }
    }
    
    private func selectedImageView(_ image: UIImage) -> some View {
        ZStack {
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
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.baseColor20)
                    .frame(width: 144, height: 180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.mainColor0, lineWidth: 4)
                    )
                
                Image(systemName: "photo.badge.plus.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 40))
            }
        }
    }
}

// MARK: - Input Fields Components
extension AddBookView {
    
    private var inputFields: some View {
        VStack {
            labelSelector
            nameInputField
            registerButton
        }
    }
    
    private var labelSelector: some View {
        LabelSelector(
            labels: Binding(
                get: { labelList },
                set: { newLabels in
                    labelList = newLabels
                    // 他のViewとの同期を保つ
                    LabelStorage.save(newLabels)
                }
            ),
            selectedLabel: $selectedLabel
        )
        .onChange(of: labelList) { _ in
            // ラベルリストが変更された時の処理
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
        }
    }
    
    private var registerButton: some View {
        BasicButton(label: "登録", width: 56, height: 40) {
            saveNewMaterial()
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(bookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

// MARK: - Actions
extension AddBookView {
    
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
    
    private func saveNewMaterial() {
        let trimmedName = bookName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newMaterial = Material(context: viewContext)
        newMaterial.id = UUID()
        newMaterial.name = trimmedName
        newMaterial.label = selectedLabel.isEmpty ? "未分類" : selectedLabel
        newMaterial.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
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
            isShowing = false
            print("✅ 新しい教材を保存: \(trimmedName) - \(selectedLabel)")
        } catch {
            print("❌ 新規教材保存エラー: \(error.localizedDescription)")
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
}
