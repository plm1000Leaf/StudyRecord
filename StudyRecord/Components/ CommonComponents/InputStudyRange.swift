//
//  InputTextField.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/28.
//
import SwiftUI
import CoreData

enum StudyRangeType {
    case start
    case end
}

struct InputStudyRange: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @State private var text: String = ""
    @State private var isInputting: Bool = false
    private let maxCharacters = 15
    var type: StudyRangeType  
    var placeholder: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil



    var body: some View {
        Group {
            if isInputting {
                inputStudyRange
            } else {
                displayStudyRange
            }
        }
            .onAppear {
                if type == .start {
                    text = dailyRecord.startPage ?? ""
                } else {
                    text = dailyRecord.endPage ?? ""
                }
            }
    }
}

extension InputStudyRange {
    private var inputStudyRange: some View {
        TextField(placeholder, text: $text,onCommit: {
            isInputting = false
            isInputting = false
            switch type {
            case .start:
                DailyRecordManager.shared.updateStartPage(text, for: dailyRecord, context: viewContext)
            case .end:
                DailyRecordManager.shared.updateEndPage(text, for: dailyRecord, context: viewContext)
            }
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

//#Preview {
//    InputStudyRange(placeholder: "入力して", dailyRecord: <#DailyRecord#>)
//}
