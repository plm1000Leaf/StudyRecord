//
//  switchButton.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/18.
//
import SwiftUI

struct SwitchButton: View {
    @State private var isOn = false

    var body: some View {
        Toggle("スイッチ", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle()) // デフォルトのスイッチスタイル
            .padding()
            .frame(width: 48, height: 24)
            
    }
}

struct SwitchButton_Previews: PreviewProvider {
    static var previews: some View {
        SwitchButton()
    }
}
