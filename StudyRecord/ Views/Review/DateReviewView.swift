//
//  DateReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/22.
//

import SwiftUI

struct DateReviewView: View {
    
    @State private var selectedRowIndex: Int? = nil
    @State private var isTapEditButton = false

    
    var body: some View {
            VStack{

                DateReviewHeader
                
                ScrollView {
                    ForEach(0..<30, id: \.self){ index in
                        Group {
                            if selectedRowIndex == index {
                                if isTapEditButton {
                                    FillTodayReview
                                } else {
                                    SelectReview
                                }
                            } else {
                                DateReviewRow
                                    .onTapGesture {
                                        selectedRowIndex = index
                                    }
                            }
                        }
                    }
                }
            }
            
        

    }
    
}

#Preview {
    DateReviewView()
}

extension DateReviewView {
    private var DateReviewRow: some View {
        HStack(alignment: .top, spacing: 32){
            VStack(alignment: .trailing){
                Text("30")
                    .font(.system(size: 32))
                Text("金")
                    .font(.system(size: 16))
            }
            Rectangle()
                .frame(width: 248, height: 88)
        }
        .padding(.bottom, 32)
    }
    
    private var DateReviewHeader: some View {
        ZStack{
            
            Rectangle()
                .frame(width: 392, height: 88)
            HStack{
                VStack(alignment: .leading){
                     HStack{
                            Image(systemName: "chevron.left")
                            Text("月")
                        }
        
                    
                    HStack(alignment: .bottom){
                        Text("2025")
                            .font(.system(size: 16))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                        
                        Text("1")
                            .font(.system(size: 48))
                            .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    }
                }
                Spacer()
            
            }
            .padding(.leading, 28)
            .foregroundColor(.white)
        }
    }
    
    private var SelectReview: some View {
        HStack(alignment: .top, spacing: 32){
            VStack(alignment: .trailing){
                Text("30")
                    .font(.system(size: 32))
                Text("金")
                    .font(.system(size: 16))
            }
            ZStack{
                Rectangle()
                    .frame(width: 248, height: 288)
                VStack{
                    HStack{
                        Rectangle()
                            .frame(width: 96, height: 120)
                            .foregroundColor(.blue)
                        VStack(spacing: 8){
                        Text("応用情報技術者合格教本")
                            .font(.system(size: 16))
                            .frame(width: 104)
                            .foregroundColor(.blue)
                        
                            HStack{
                                Text("30")
                                    .font(.system(size: 16))
                                Text("ページ")
                                    .font(.system(size: 8))
                            }
                            Text("〜")
                                .font(.system(size: 16))
                                .bold()
                                .rotationEffect(.degrees(90))
                            HStack{
                                Text("30")
                                    .font(.system(size: 16))
                                Text("ページ")
                                    .font(.system(size: 8))
                            }

                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.bottom, 8)
                    Rectangle()
                        .frame(width: 208, height: 64)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 128){
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                        Button(action: {
                            isTapEditButton = true
                        }){
                            Circle()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                    
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    private var FillTodayReview: some View {
        HStack(alignment: .top, spacing: 32){
            VStack(alignment: .trailing){
                Text("30")
                    .font(.system(size: 32))
                Text("金")
                    .font(.system(size: 16))
            }
            ZStack{
                Rectangle()
                    .frame(width: 248, height: 288)
                VStack{
                    HStack{
                        Rectangle()
                            .frame(width: 96, height: 120)
                            .foregroundColor(.blue)
                        VStack(spacing: 8){
                        Text("応用情報技術者合格教本")
                            .font(.system(size: 16))
                            .frame(width: 104)
                            .foregroundColor(.blue)
                        
                            HStack{
                                Text("30")
                                    .font(.system(size: 16))
                                Text("ページ")
                                    .font(.system(size: 8))
                            }
                            Text("〜")
                                .font(.system(size: 16))
                                .bold()
                                .rotationEffect(.degrees(90))
                            HStack{
                                Text("30")
                                    .font(.system(size: 16))
                                Text("ページ")
                                    .font(.system(size: 8))
                            }

                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.bottom, 8)
                    Rectangle()
                        .frame(width: 208, height: 64)
                        .foregroundColor(.blue)
                    HStack{
                        
                        BasicButton(label: "確定", action: {
                            isTapEditButton = false
                        })

                            .frame(width: 56, height: 32)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 144)
                    .padding(.top, 8)

                    
                }
            }
        }
        .padding(.bottom, 32)
    }
    
}

#Preview {
   DateReviewView()
}
