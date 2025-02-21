//
//  BookSelectView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/21.
//

import SwiftUI

struct BookSelectView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView{
            VStack(spacing: 40){
                
                studyMaterialLabel
                HStack(spacing: 32){
                    
                    studyMaterial
                    studyMaterial
                    studyMaterial
                }
                .padding(.bottom, 16)
                
                studyMaterialLabel
                HStack(spacing: 32){
                    
                    studyMaterial
                    studyMaterial
                    studyMaterial
                }
                .padding(.bottom, 24)
                
                bookAddButton
                
                
            }
            .overlay(
                Button(action: {
                    dismiss() // 親ビューの状態を変更する
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .padding(8)
                },
                alignment: .topLeading // 左上に配置
            )
            
            .padding(.horizontal, 20)
        }
    }
}
#Preview {
    BookSelectView()
}

extension BookSelectView {
    private var studyMaterialLabel: some View {
        Text("資格")
            .padding(.top, 40)
            .font(.system(size: 32))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    
    private var studyMaterial: some View {
        VStack {
            Rectangle()
                .frame(width: 96, height: 120)
            Text("応用情報技術者合格教本")
                .font(.system(size: 16))
                .frame(width: 72)
        }
        .padding(.bottom, 16)
    }
    
    private var bookAddButton: some View {
        Rectangle()
            .frame(width: 96, height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
