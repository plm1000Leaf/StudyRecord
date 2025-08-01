//
//  MaterialCardView.swift
//  StudyRecord
//
//

import SwiftUI
import PhotosUI
import CoreData

struct MaterialCardView: View {
    let material: Material
    let isEditingMode: Bool
    let onMaterialSelect: ((Material) -> Void)?
    let onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditingMaterial = false
    @State private var editingMaterialName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            VStack {
                materialImage
                materialName
            }
            .padding(.bottom, 32)
            
            if isEditingMode {
                editingOverlay
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            updateMaterialImage(newItem)
        }
    }
}

// MARK: - Image Components
extension MaterialCardView {
    
    private var materialImage: some View {
        Group {
            if let imageData = material.imageData, let uiImage = UIImage(data: imageData) {
                if isEditingMode && isEditingMaterial {
                    editableImage(uiImage)
                } else {
                    selectableImage(uiImage)
                }
            } else {
                placeholderImage
            }
        }
    }
    
    private func selectableImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 96, height: 120)
            .clipped()
            .onTapGesture {
                if !isEditingMode {
                    selectMaterial()
                }
            }
    }
    
    private func editableImage(_ image: UIImage) -> some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 120)
                .clipped()
                .overlay(editingImageOverlay)
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .frame(width: 96, height: 120)
            .foregroundColor(.gray.opacity(0.3))
            .onTapGesture {
                if !isEditingMode {
                    selectMaterial()
                }
            }
    }
    
    private var editingImageOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.black)
                .opacity(0.3)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 3)
            Image(systemName: "photo.fill")
                .frame(width: 32)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Name Components
extension MaterialCardView {
    
    private var materialName: some View {
        Group {
            if isEditingMode && isEditingMaterial {
                nameEditField
            } else {
                nameDisplay
            }
        }
    }
    
    private var nameEditField: some View {
        TextField("教材名", text: $editingMaterialName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 96)
            .multilineTextAlignment(.center)
            .onSubmit {
                saveMaterialEdit()
            }
    }
    
    private var nameDisplay: some View {
        Text(material.name ?? "")
            .font(.system(size: 16))
            .frame(width: 72, height: 100, alignment: .center)
            .multilineTextAlignment(.center)
//            .lineLimit(2)
    }
}

// MARK: - Editing Overlay
extension MaterialCardView {
    
    private var editingOverlay: some View {
        VStack {
            HStack {
                Spacer()
                editActionButton
            }
            Spacer()
        }
    }
    
    private var editActionButton: some View {
        Button(action: {
            if isEditingMaterial {
                deleteMaterial()
            } else {
                startMaterialEdit()
            }
        }) {
            Image(systemName: isEditingMaterial ? "trash.circle.fill" : "pencil.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(isEditingMaterial ? .red : .blue)
                .background(Circle().fill(Color.white))
        }
        .offset(x: 16, y: 88)
    }
}

// MARK: - Actions
extension MaterialCardView {
    
    private func selectMaterial() {
        onMaterialSelect?(material)
        onDismiss()
    }
    
    private func startMaterialEdit() {
        editingMaterialName = material.name ?? ""
        isEditingMaterial = true
    }
    
    private func saveMaterialEdit() {
        material.name = editingMaterialName
        do {
            try viewContext.save()
            isEditingMaterial = false
        } catch {
            print("教材名保存エラー: \(error.localizedDescription)")
        }
    }
    
    private func deleteMaterial() {
        viewContext.delete(material)
        do {
            try viewContext.save()
        } catch {
            print("教材削除エラー: \(error.localizedDescription)")
        }
    }
    
    private func updateMaterialImage(_ newItem: PhotosPickerItem?) {
        guard let item = newItem else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    material.imageData = uiImage.jpegData(compressionQuality: 0.8)
                    try? viewContext.save()
                    isEditingMaterial = false
                }
            }
        }
    }
}
