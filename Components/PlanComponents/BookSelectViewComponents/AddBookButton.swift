//
//  AddBookButton.swift
//  StudyRecord
//
//

import SwiftUI

struct AddBookButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 96, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                style: StrokeStyle(lineWidth: 4, dash: [5, 4])
                            )
                            .foregroundColor(Color.mainColor0)
                    )
                
                Image(systemName: "plus")
                    .foregroundColor(Color.mainColor0)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 80)
    }
}
