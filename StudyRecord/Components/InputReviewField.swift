import SwiftUI

struct InputReviewField: View {
    @State private var text: String = ""
    @State private var isEditing: Bool = false
    private let maxCharacters = 35
    
    var body: some View {
        VStack(spacing: 16) {
            if isEditing {
                ZStack{
                    Rectangle()
                        .frame(width: 208, height: 64)
                        .foregroundColor(.green)
                    CustomTextEditor(text: $text, maxCharacters: maxCharacters)
                        .frame(width: 200, height: 64)
                        .padding(.leading, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                }
            } else {
                ZStack{
                    Rectangle()
                        .frame(width: 208, height: 64)
                        .foregroundColor(.green)
                    Text(text.isEmpty ? "a" : text)
                        .frame(width: 200, height: 64)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // 改行を有効化
                        .padding(.leading, 8)

                }
            }

            if isEditing {
                HStack {
                    BasicButton(label: "確定", action: {
                        isEditing.toggle()
                    })
                    .frame(width: 56, height: 40)
                    .foregroundColor(.blue)
                }
                .padding(.leading, 144)

            } else {
                HStack(spacing: 120) {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
    }
}

struct InputReviewField_Previews: PreviewProvider {
    static var previews: some View {
        InputReviewField()
    }
}
