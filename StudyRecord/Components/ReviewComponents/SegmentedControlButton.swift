//
//  SegmentedControlButton.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/14.
//

import SwiftUI

struct SegmentedControlButton: View {
    @Binding var selectedSegment: Int

    var body: some View {
        VStack {
            // セグメンテッドコントロールの作成
            Picker("選択肢", selection: $selectedSegment) {
                Text("オプション1").tag(0)
                Text("オプション2").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle()) // セグメンテッドスタイルを指定

      
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlButton(selectedSegment: .constant(0))
    }
}
