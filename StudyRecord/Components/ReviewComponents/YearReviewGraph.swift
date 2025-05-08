//
//  YearReviewGraph.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/08.
//

import SwiftUI

struct YearReviewGraph: View {
    let monthlyData: [Double] = [100, 120, 80, 150, 170, 130, 160, 140, 110, 180, 200, 190]
    let monthLabels: [String] = ["1月", "2月", "3月", "4月", "5月", "6月",
                                 "7月", "8月", "9月", "10月", "11月", "12月"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(monthlyData.indices, id: \.self) { index in
                    VStack {
                        Text("\(Int(monthlyData[index]))")
                            .font(.caption)
                            .padding(.bottom, 4)
                        Rectangle()
                            .foregroundColor(.mainColor0)
//                            .fill(Color.teal)
                            .frame(width: 24, height: CGFloat(monthlyData[index]))
                        Text(monthLabels[index])
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                            .frame(width: 40)
                    }
                }
            }
            .padding()
        }
        .frame(height: 300)
    }
}

#Preview {
    YearReviewGraph()
}
