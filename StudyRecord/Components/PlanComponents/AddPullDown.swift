//
//  AddPullDown.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/22.
//

import SwiftUI

struct AddPullDown: View {
    @State private var isInputting: Bool = false
    var body: some View {
        if isInputting == true {
            VStack(spacing:0){
                afterTapButton
                tagSelectField
            }
        } else {
            beforeTapButton
        }
    }
}

#Preview {
    AddPullDown()
}

extension AddPullDown {
    
    private var beforeTapButton: some View {
        Button(action: {isInputting = true}){
            ZStack{
                Rectangle()
                    .frame(width: 156, height: 32)
                    .padding(.bottom, 8)
                    .foregroundColor(.blue)
                HStack{
                    Text("タグを選択")
                        .font(.system(size: 16))
                    Spacer()
                        .frame(width: 24)
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.black)
                .padding(.bottom, 8)
            }
            .padding(.bottom, 88)
        }
    }
    
    private var afterTapButton: some View {
        Button(action: {isInputting = false}) {
            ZStack{
                Rectangle()
                    .frame(width: 156, height: 32)
                    .padding(.bottom, 8)
                    .foregroundColor(.blue)
                HStack{

                    Spacer()
                        .frame(width: 110)
                    Image(systemName: "chevron.up")
                }
                .foregroundColor(.black)
                .padding(.bottom, 8)
            }
        }
    }
    
    private var tagSelectField: some View {
        Rectangle()
            .frame(width: 156, height: 96)
            .foregroundColor(.blue)
    }
}
