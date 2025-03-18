//
//  PullDown.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/18.
//

import SwiftUI

struct PullDown: View {
    @State private var selectedItem = "ページ" // 初期値を明示的に設定

    let options = ["-", "ページ", "章"]

    var body: some View {
        Picker("選択してください", selection: $selectedItem) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .tag(option)
                    .fixedSize(horizontal: true, vertical: false) // 折り返しを防ぐ
            }
        }
        .pickerStyle(MenuPickerStyle()) // プルダウンメニュー風
        .frame(width: 100) // 必要に応じて幅を調整
        .padding(4)
    }
}


#Preview {
    PullDown()
}
