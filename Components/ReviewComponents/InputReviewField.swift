
import SwiftUI
import CoreData

struct InputReviewField: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dailyRecord: DailyRecord
    @Binding var isTapShareButton: Bool
    @Binding var reviewText: String
    @State private var isEditing: Bool = false
    private let maxCharacters = 35
    
    var body: some View {
        VStack(spacing: 16) {
            if isEditing {
                editReviewField
                editReviewButton
                
            } else {
                displayReviewField
                displayReviewButton
            }


        }
        .padding()
        .onAppear {
            reviewText = dailyRecord.review ?? ""
        }
    }
}


extension InputReviewField {
    private var displayReviewField: some View {
        ZStack{
            Rectangle()
                .frame(width: 208, height: 64)
                .foregroundColor(.mainColor10)
            Text(reviewText.isEmpty ? "振り返りを入力" : reviewText)
                .frame(width: 200, height: 64)
                .multilineTextAlignment(.leading)
                .lineLimit(nil) // 改行を有効化
                .padding(.leading, 8)

        }
    }
    
    private var editReviewField: some View {

        CustomTextEditor(text: $reviewText, maxCharacters: maxCharacters)
                .frame(width: 200, height: 64)
                .padding(.leading, 8)
                .background(.baseColor10)
                .cornerRadius(8)
    }
    
    private var displayReviewButton: some View {
        HStack(spacing: 120) {
            Button(action: {
                isTapShareButton = true
            }) {
                Image(systemName:"square.and.arrow.up")
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray0)
            }
            Button(action: {
                isEditing.toggle()
            }) {
                ZStack{
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.accentColor1)
                    Image(systemName:"square.and.pencil")
                        .frame(width: 32, height: 32)
                        .foregroundColor(.baseColor10)
                }
            }
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
