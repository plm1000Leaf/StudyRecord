
import SwiftUI
import CoreData

struct InputReviewField: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @Binding var reviewText: String
    @State private var isEditing: Bool = false
    private let maxCharacters = 48
    
    let isChecked: Bool
    
    
    // ★ 追加：編集開始時に呼ばれるコールバック
     let onBeginEditing: (() -> Void)?

     init(
         dailyRecord: DailyRecord,
         reviewText: Binding<String>,
         isChecked: Bool,
         onBeginEditing: (() -> Void)? = nil   // <- デフォルト引数で既存呼び出しも壊さない
     ) {
         self.dailyRecord = dailyRecord
         self._reviewText = reviewText
         self.isChecked = isChecked
         self.onBeginEditing = onBeginEditing
     }
    
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
            isEditing = true
            // 編集開始を親に知らせる
            onBeginEditing?()
            
        }) {
            ZStack{
                Rectangle()
                    .frame(width: 208, height: 104)
                    .cornerRadius(8)
                    .foregroundColor(isChecked ? .mainColor10 : .notCheckedColor10)
                Text(reviewText.isEmpty ? "振り返りをタップで入力" : reviewText)
                    .frame(width: 200, height: 104)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .foregroundColor(isChecked ?  .baseColor20: .baseColor20)
                
            }
        }
        .padding(.bottom, 40)
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
                
                Button(action: {
                    DailyRecordManager.shared.updateReview(reviewText, for: dailyRecord, context: viewContext)
                    isEditing = false
                }) {
                    ZStack{
                        Rectangle()
                            .frame(width: 400, height: 40)
                            .cornerRadius(8)
                            .opacity(0.0)
                        BasicButton(label: "確定", width: 56, height: 32)
                    }
                }
            }
            .padding(.leading, 144)
            
        }
}
