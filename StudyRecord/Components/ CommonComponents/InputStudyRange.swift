//
//  InputTextField.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/28.
//
import SwiftUI

struct InputStudyRange: View {
    var placeholder: String
    @State private var text: String = ""
    @State private var isInputting: Bool = false
    private let maxCharacters = 15
    var width: CGFloat? = nil
    var height: CGFloat? = nil

    var body: some View {
            if isInputting {
                inputStudyRange
            } else {
                displayStudyRange
            }

            
    }
}

extension InputStudyRange {
    private var inputStudyRange: some View {
        TextField(placeholder, text: $text,onCommit: {
            isInputting = false
        })
            .padding(10)
            .background(Color.baseColor10)
            .cornerRadius(8)
            .onChange(of: text) { newValue in
                if newValue.count > maxCharacters {
                    text = String(newValue.prefix(maxCharacters))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.mainColor0, lineWidth: 1)
            )
            .padding(.horizontal)
            .frame(width: width, height: height)
            .padding(.vertical, height == nil ? 8 : 0)
    }
    
    private var displayStudyRange: some View {
        Button(action: {
            isInputting = true

        }){
            ZStack{
                Text(text.isEmpty ? "入力" : text)
                    .frame(width:80,height: 80)
                    .foregroundColor(.black)

            }
        }
        .frame(width: width, height: height)
        .padding(.vertical, height == nil ? 8 : 0)
    }
}

#Preview {
    InputStudyRange(placeholder: "入力して")
}
