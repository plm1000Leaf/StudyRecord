//
//  DateReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/22.
//

import SwiftUI

struct DateReviewView: View {
    var body: some View {
        VStack{

            DateReviewHeader
            
            ScrollView {
                ForEach(0..<30){ _ in
                    VStack{
                        DateReviewRow

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
        HStack(spacing: 32){
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
        Rectangle()
            .frame(width: 392, height: 96)
    }
    
}
