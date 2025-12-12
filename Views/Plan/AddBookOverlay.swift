//
//  AddBookView.swift
//  StudyRecord
//
//
//

import SwiftUI
import CoreData
import UIKit

struct AddBookOverlay: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var bookName = ""
    @State private var selectedLabel = ""
    @State private var selectedImage: UIImage?
    @State private var canRegister = false
    @State private var isLabelAddModalPresented = false
    @State private var isShowingImageSourceOptions = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibrary = false
    @State private var isCameraUnavailableAlertPresented = false
    @Binding var labelList: [String]
    @Binding var isShowing: Bool

    let onDismiss: () -> Void

    private let maxCharacters = 25

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
            .onAppear {
                // ラベルリストの同期
                syncLabelList()
            }

        }
        .sheet(isPresented: $isLabelAddModalPresented) {
            LabelAddModal(labels: $labelList, selectedLabel: $selectedLabel)
              .presentationDetents([.fraction(0.15)])
          }

        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePickerView(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePickerView(sourceType: .camera, selectedImage: $selectedImage)
        }
        .confirmationDialog("写真の入力方法", isPresented: $isShowingImageSourceOptions, titleVisibility: .visible) {
            Button("カメラロールから選択") {
                isShowingPhotoLibrary = true
            }
            Button("カメラで撮影") {
                presentCamera()
            }
            Button("キャンセル", role: .cancel) {}
        }
        .alert("カメラが利用できません", isPresented: $isCameraUnavailableAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("設定からカメラへのアクセスを許可してください。")
        }

        }
    }

// MARK: - Image Selector Components
extension AddBookOverlay {

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
        Button {
            isShowingImageSourceOptions = true
        } label: {
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

                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white).frame(width: 37, height: 37))
                        .offset(y: -8)
                }
                .frame(width: 128, height: 96)
            }
        }
    }

    private var openCameraRollButton: some View {
        Button {
            isShowingImageSourceOptions = true
        } label: {
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
extension AddBookOverlay {

    private var inputFields: some View {
        HStack{
            VStack {
                labelSelector
                nameInputField
            }
            .padding(.top, 16)
            .padding(.leading, 64)
            registerMaterialButton
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
            saveNewMaterial()
        }) {
            BasicButton(
                label: "登録",
                color:canRegister ? nil : .gray,
                width: 56,
                height: 40
            )
        }
        .padding(.top, 90)
        .padding(.trailing, 48)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(!canRegister)
    }
}

// MARK: - Actions
extension AddBookOverlay {

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
            print("✅ 新しいテーマを保存: \(trimmedName) - \(selectedLabel)")
        } catch {
            print("❌ 新規テーマ保存エラー: \(error.localizedDescription)")
        }
    }

    private func resetFields() {
        bookName = ""
        selectedImage = nil
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

    private func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            isShowingCamera = true
        } else {
            isCameraUnavailableAlertPresented = true
        }
    }
}

