//
//  YearReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/26.
//

import SwiftUI

struct YearReviewView: View {
    var body: some View {
        VStack(spacing: 16){
            header
            monthButton
            segmentedControl

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    YearReviewView()
}

extension YearReviewView {
    private var header: some View {
        HStack{
            Text("2025")
                .font(.system(size: 48))
            Spacer()
        }
        .padding([.top, .bottom], 48)
        .frame(maxWidth: 312, alignment: .leading)
    }
    
    private var monthButton: some View {
        ForEach(0..<4) { _ in
            HStack(spacing: 16){
                ForEach(0..<3) {_ in
                    Rectangle()
                        .frame(width: 104, height: 104)
                }
            }
        }

    }
    
    private var segmentedControl: some View {
        Rectangle()
            .frame(width: 264, height: 48)
            .padding(.top, 24)
    }
    
    
}
