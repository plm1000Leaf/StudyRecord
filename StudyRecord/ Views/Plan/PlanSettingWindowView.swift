//
//  PlanSettingWindowView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/20.
//

import SwiftUI

struct PlanSettingWindowView: View {
    
    @State private var isTapBookSelect = false
    @State private var startPage: String = ""
    @State private var endPage: String = ""
    @State private var isDialogShown = false
    @Binding var isOn: Bool
    var onClose: () -> Void
    
    var body: some View {
        ZStack{
            
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            windowBase
            VStack(spacing: 24){

                windowTitle
                VStack(alignment: .leading){
                    inputLearningContent
                    inputScheduledTime
                }
                
                BasicButton(label: "決定"){
                    print("Doneボタンが押されました")
                }
                    .frame(width: 128, height: 48)

            }

            .sheet(isPresented: $isTapBookSelect) {
                BookSelectView()
            }
            .frame(width: 336, height: 520)
            .overlay(
                Button(action: {
                    onClose() // 親ビューの状態を変更する
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .padding(8)
                },
                alignment: .topLeading // 左上に配置
            )
            
        }
        
        
    }
}



extension PlanSettingWindowView {
    private var windowTitle: some View {
        HStack(alignment: .firstTextBaseline) {
            
            Text("30")
                .font(.system(size: 48))
            
            Text("(木)")
                .font(.system(size: 24))
                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
            
        }
        .padding(.top, -8)
        
        
        
        
    }
    
    
    private var inputLearningContent: some View {
        VStack(alignment: .leading){
            Text("学習予定")
                .font(.system(size: 24))
            
            HStack(spacing:40){
                
                Button(action: {
                    isTapBookSelect.toggle()
                }){
                    Rectangle()
                        .frame(width: 104, height: 120)
                        .foregroundColor(.mainColor0)
                }
                .padding(.leading, 16)
                
                
                VStack(spacing: 8){
                    HStack(spacing: -8){
                        InputStudyRange(placeholder: "ページ数")
                        
                        PullDown()
                        
                    }
                    
                    Text("〜")
                        .font(.system(size: 32))
                        .bold()
                        .rotationEffect(.degrees(90))
                    HStack(spacing: -8){
                        InputStudyRange(placeholder: "ページ数")
                        PullDown()
                    }
                }
                
            }
            .padding(.bottom, 32)
            
        }
    }
    
    
    private var inputScheduledTime: some View {
        VStack(alignment: .leading){
            Text("予定時間")
                .font(.system(size: 24))
            
            HStack{
                TimeSelectButton()
                    .frame(width: 180 , height: 40)
                
                VStack(spacing: 24){
                    HStack {
                        Text("アラーム")
                            .font(.system(size: 16))
                        Toggle(isOn: $isOn) {
                            EmptyView() // ラベルを外に出す場合は空
                        }
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                
                
                    if isOn {
                        Button(action: {
                            isDialogShown = true
                        }){
                            HStack {
                                Text("繰り返し")
                                Text("なし")
                            }
                            .font(.system(size: 16))
                        }
                        .alert(isPresented: $isDialogShown) {
                            Alert(
                                title: Text("毎週木曜日の14時30分\nにアラームを鳴らします"),
                                message: Text("本当に設定してもよろしいですか？"),
                                primaryButton: .destructive(Text("はい")) {
                                    print("はいが選択されました")
                                },
                                secondaryButton: .cancel(Text("いいえ"))
                            )
                        }
                    }
                }
            }
        }
    }
    
    
    private var windowBase: some View {
        Rectangle()
            .fill(Color.baseColor0)
            .frame(width: 336, height: 520)
    }
    
}
