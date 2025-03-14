//
//  SegmentedControlButton.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/14.
//

import SwiftUI

struct SegmentedControlButton: View {
    // 選択されたセグメントを保存する状態変数
    @State private var selectedSegment = 0

    var body: some View {
        VStack {
            // セグメンテッドコントロールの作成
            Picker("選択肢", selection: $selectedSegment) {
                Text("オプション1").tag(0)
                Text("オプション2").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle()) // セグメンテッドスタイルを指定

            // 選択されたオプションを表示
//            Text("選択されたオプション: \(selectedSegment + 1)")
//                .padding()
      
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlButton()
    }
}
