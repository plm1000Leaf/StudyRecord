//
//  BookSelectView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/21.
//

import SwiftUI

struct BookSelectView: View {
    var body: some View {
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
            .padding(.bottom, 16)
            
        bookAddButton
        

        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    BookSelectView()
}

extension BookSelectView {
    private var studyMaterialLabel: some View {
        Text("資格")
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
    }
    
    private var bookAddButton: some View {
        Rectangle()
            .frame(width: 96, height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
