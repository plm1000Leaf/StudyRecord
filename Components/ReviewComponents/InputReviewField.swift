
import SwiftUI
import CoreData

struct InputReviewField: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @Binding var reviewText: String
    @State private var isEditing: Bool = false
    private let maxCharacters = 48
    
    let isChecked: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if isEditing {
                editReviewField
                editReviewButton
            } else {
                displayReviewField
            }

        }
        .padding()
        .frame(width: 248)
        .onAppear {
            reviewText = dailyRecord.review ?? ""
        }
    }
}


extension InputReviewField {
    private var displayReviewField: some View {
        Button(action: {
            isEditing.toggle()
        }) {
            ZStack{
                Rectangle()
                    .frame(width: 208, height: 104)
                    .cornerRadius(8)
                    .foregroundColor(isChecked ? .mainColor10 : .notCheckedColor10)
                Text(reviewText.isEmpty ? "振り返りを入力" : reviewText)
                    .frame(width: 200, height: 104)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil) // 改行を有効化
//                    .padding(.leading, 8)
                
            }
            .padding(.bottom, 40)
        }
    }
    
    private var editReviewField: some View {
 
            CustomTextEditor(text: $reviewText, maxCharacters: maxCharacters)
                .frame(width: 200, height: 104)
                .padding(.leading, 8)
                .background(.baseColor10)
                .cornerRadius(8)
                .onSubmit {
                    DailyRecordManager.shared.updateReview(reviewText, for: dailyRecord, context: viewContext)
                    isEditing = false
                }
        
    }
    
    private var editReviewButton: some View {
        HStack {
            BasicButton(label: "確定", width: 56, height: 32) {
                DailyRecordManager.shared.updateReview(reviewText, for: dailyRecord, context: viewContext)
                isEditing = false
            }

        }
        .padding(.leading, 144)
    }
}
