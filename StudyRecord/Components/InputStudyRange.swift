//
//  InputTextField.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/28.
//
import SwiftUI

struct InputStudyRange: View {
    var placeholder: String
    @Binding var text: String
    @State private var userInput: String = ""

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

#Preview {
    InputStudyRange(placeholder: "入力して", text: .constant(""))
}
