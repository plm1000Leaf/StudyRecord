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
                .frame(width: 344, height: 448)
                .overlay(
                    Button(action: {
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .padding(16)
                            .padding(.top, -8)
                    },
                    alignment: .topLeading
                )
            
            
            VStack(spacing: 40) {
                imageSelector
                inputFields
            }
            .onChange(of: selectedPhotoItem) { newItem in
                loadSelectedImage(newItem)
            }
            .onAppear {
                // ラベルリストの同期
                syncLabelList()
            }
            
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
    
    private var photoPickerButton: some View {
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
extension AddBookView {
    
    private var inputFields: some View {
        HStack{
            VStack {
                labelSelector
                nameInputField
            }
            .padding(.top, 16)
            .padding(.leading, 64)
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
                .onChange(of: bookName) { newValue in
                    if newValue.count > maxCharacters {
                        bookName = String(newValue.prefix(maxCharacters))
                    }
                }
        }
    }
    
    private var registerButton: some View {
        BasicButton(label: "登録", width: 56, height: 40) {
            saveNewMaterial()
        }
        .padding(.top, 90)
        .padding(.trailing, 48)
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
            // 保存成功後にビューを閉じる
            onDismiss()
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

//#Preview {
//    BookSelectView()
//        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//}
