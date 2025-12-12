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
        let baseWidth = width ?? 80
        let baseHeight = height ?? 80

        return TextField(placeholder, text: $text,onCommit: {
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
            .frame(width: baseWidth, height: baseHeight)
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
        let baseWidth = width ?? 40
        let baseHeight = height ?? 40
        let textFrameHeightSize = max(Int(baseHeight), min(text.count * 6, 60))
        let textFrameWidthSize = max(Int(baseWidth * 0.625), min(text.count * 9, 90))

        if !isInputting && text.isEmpty {
            return AnyView(
                Button(action: {
                    isInputting = true
                }){
                    BasicButton(label:"範囲を入力", colorOpacity: 0.5, width: baseWidth, height: baseHeight)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                style: StrokeStyle(lineWidth: 2, dash: [5, 4])
                            )
                            .foregroundColor(Color.mainColor0)
                    )
            )
        } else {
            return AnyView(
                Button(action: {
                    isInputting = true
                }) {
                    Text(text)
                        .frame(width: baseWidth, height: baseHeight)
                        .foregroundColor(.black)
                }
                .frame(width: baseWidth, height: baseHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mainColor0, lineWidth: 1)
                        .frame(width: max(CGFloat(textFrameWidthSize), baseWidth),
                               height: max(CGFloat(textFrameHeightSize), baseHeight))
                )
            )
        }
    }
}
