import SwiftUI
import CoreData

struct InputStudyRange: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var recordService: DailyRecordService
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
            updateTextFromService()
        }
        .onChange(of: recordService.currentRecord) { _ in
            updateTextFromService()
        }
    }
}

extension InputStudyRange {
    private var inputStudyRange: some View {
        TextField(placeholder, text: $text,onCommit: {
            isInputting = false
            commitChanges()
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
    
    private func updateTextFromService() {
        let studyRange = recordService.getStudyRange()
        switch type {
        case .start:
            text = studyRange.startPage
        case .end:
            text = studyRange.endPage
        }
    }
    
    private func commitChanges() {
        switch type {
        case .start:
            recordService.updateStartPage(text, context: viewContext)
        case .end:
            recordService.updateEndPage(text, context: viewContext)
        }
    }
    
    private var displayStudyRange: some View {
        let textFrameHeightSize = max(40, min(text.count * 6, 60))
        let textFrameWidthSize = max(50, min(text.count * 9, 90))

        if !isInputting && text.isEmpty {
            return AnyView(
                BasicButton(label:"学習範囲を入力", colorOpacity: 0.5, width: 80, height: 64) {
                    isInputting = true
                }
            )
        } else {
            return AnyView(
                Button(action: {
                    isInputting = true
                }) {
                    Text(text)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.black)
                }
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mainColor0, lineWidth: 1)
                        .frame(width: CGFloat(textFrameWidthSize),
                               height: CGFloat(textFrameHeightSize))
                )
            )
        }
    }
}
