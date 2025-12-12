//
//  MaterialCardView.swift
//  StudyRecord
//
//

import SwiftUI
import PhotosUI
import CoreData

struct MaterialCard: View {
    let material: Material
    let isEditingMode: Bool
    let onMaterialEdit: (Material) -> Void
    let onMaterialSelect: ((Material) -> Void)?
    let onDismiss: () -> Void

    
    @Binding var activeEditingLabel: String?
    @Binding var activeEditingMaterialID: UUID?
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditingMaterial = false
    @State private var editingMaterialName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(spacing: -8){
                materialImage
                materialName
//                    .padding(.top, -16)
            }
            
            if isEditingMode {
                editingOverlay
            }
        }
        .frame(height: 250, alignment: .top)
        .onChange(of: selectedPhotoItem) { newItem in
            updateMaterialImage(newItem)
        }
        .onChange(of: activeEditingMaterialID) { newID in
            isEditingMaterial = (newID == material.id)
        }
        .onChange(of: activeEditingLabel) { _ in
            if activeEditingLabel != nil {
                isEditingMaterial = false
            }
        }
        .alert("テーマを削除", isPresented: $showDeleteAlert) {
            Button("削除", role: .destructive) {
                deleteMaterial()
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("「\(material.name ?? "")」を削除しますか？")
        }
    }
}

// MARK: - Image Components
extension MaterialCard {
    
    private var materialImage: some View {
        Group {
            if let imageData = material.imageData, let uiImage = UIImage(data: imageData) {
                if isEditingMode && isEditingMaterial {
                    editableImage(uiImage)
                } else {
                    selectableImage(uiImage)
                }
            } else {
                if isEditingMode && isEditingMaterial {
                    editablePlaceholderImage
                } else {
                    placeholderImage
                }
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
        ZStack{
            Rectangle()
                .frame(width: 96, height: 120)
                .foregroundColor(.gray.opacity(0.3))
                .onTapGesture {
                    if !isEditingMode {
                        selectMaterial()
                    }
                }
            VStack(spacing: 8){
                Image(systemName:"photo")
                    .frame(width: 16)
                    .foregroundColor(.gray10)
                Text("No Image")
            }
        }
    }
    
    private var editablePlaceholderImage: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                Rectangle()
                    .frame(width: 96, height: 120)
                    .foregroundColor(.gray.opacity(0.3))
                
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .frame(width: 16)
                        .foregroundColor(.gray10)
                    Text("No Image")
                }
            }
            .overlay(editingImageOverlay)
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
extension MaterialCard {
    
    private var materialName: some View {
        Group {
            if isEditingMode && isEditingMaterial {
                VStack(spacing: -10){
                        nameEditField
                        confirmedMaterialNameButton
                }
            } else {
                nameDisplay
            }
        }
    }
    
    private var nameEditField: some View {

        ZStack {
            Rectangle()
                .frame(width: 88, height: 72)
                .foregroundColor(.white)
            
            CustomTextEditor(text: $editingMaterialName, maxCharacters: 35)
                .frame(width: 72, height: 100)
                .padding(.top, 26)
                .multilineTextAlignment(.center)
                .onSubmit {
                    saveMaterialEdit()
                }

        }

    }
    
    private var confirmedMaterialNameButton: some View {
        Button(action: {
            saveMaterialEdit()
        }) {
            BasicButton(label: "確定", width: 40, height: 32)
                .padding(.leading, 36)
        }

    }
    
    private var nameDisplay: some View {
        Text(material.name ?? "")
            .font(.system(size: 16))
            .padding(.top, 16)
            .frame(width: 72, height: 120, alignment: .center)
            .multilineTextAlignment(.center)

    }
}

// MARK: - Editing Overlay
extension MaterialCard {
    
    private var editingOverlay: some View {
        VStack {
            HStack {
                Spacer()
                actionMaterialButton
            }
            Spacer()
        }
    }
    
    private var actionMaterialButton: some View {
        Button(action: {
            if isEditingMaterial {
                showDeleteAlert = true
            } else {
                startMaterialEdit()
                onMaterialEdit(material)
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
extension MaterialCard {
    
    private func selectMaterial() {
        onMaterialSelect?(material)
        onDismiss()
    }
    
    private func startMaterialEdit() {
        editingMaterialName = material.name ?? ""
        isEditingMaterial = true
        activeEditingMaterialID = material.id
        activeEditingLabel = nil
    }
    
    private func saveMaterialEdit() {
        material.name = editingMaterialName
        do {
            try viewContext.save()
            isEditingMaterial = false
            activeEditingMaterialID = nil
        } catch {
            print("テーマ名保存エラー: \(error.localizedDescription)")
        }
    }
    
    private func deleteMaterial() {
        viewContext.delete(material)
        do {
            try viewContext.save()
            isEditingMaterial = false
            if activeEditingMaterialID == material.id {
                activeEditingMaterialID = nil
            }
        } catch {
            print("テーマ削除エラー: \(error.localizedDescription)")
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
                    activeEditingMaterialID = nil
                }
            }
        }
    }
}
