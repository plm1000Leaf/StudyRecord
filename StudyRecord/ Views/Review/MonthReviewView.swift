//
//  MonthReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/25.
//

import SwiftUI

struct MonthReviewView: View {
    var body: some View {
        VStack(alignment: .leading ,spacing: 56){
            HStack(alignment: .bottom){
                Text("2025")
                    .font(.system(size: 16))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                
                Text("1")
                    .font(.system(size: 48))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
            }
            .padding(.top, 40)
            
            Rectangle()
                .frame(width: 336, height: 352)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    MonthReviewView()
}
