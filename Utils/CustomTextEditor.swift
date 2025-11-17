import SwiftUI
import UIKit

/// 日本語入力に対応したカスタムテキストエディタ
struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var maxCharacters: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true // スクロールを有効化
        textView.returnKeyType = .default // 改行を有効化
        textView.autocorrectionType = .no // 自動修正を無効化（必要なら）
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let currentText = textView.text,
                  let textRange = Range(range, in: currentText) else {
                return true
            }

            let replacementCount = text.count
            let currentCount = currentText.count
            let replacingCount = currentText[textRange].count
            let baseCount = currentCount - replacingCount
            let newCount = baseCount + replacementCount

            if newCount <= parent.maxCharacters {
                return true
            }

            let allowedAdditional = parent.maxCharacters - baseCount
            guard allowedAdditional > 0 else {
                return false
            }

            let limitedText = String(text.prefix(allowedAdditional))
            textView.text = currentText.replacingCharacters(in: textRange, with: limitedText)
            if let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + limitedText.count) {
                textView.selectedTextRange = textView.textRange(from: startPosition, to: startPosition)
            }
            parent.text = textView.text
            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            // 日本語変換中（未確定文字あり）の場合は更新を遅らせる
            if let _ = textView.markedTextRange {
                return
            }

            if textView.text.count > parent.maxCharacters {
                textView.text = String(textView.text.prefix(parent.maxCharacters))
            }
            parent.text = textView.text
        }

        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            textView.resignFirstResponder() // キーボードを閉じる
            return true
        }
    }
}

