//
//  YearReviewGraphView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/14.
//

import SwiftUI

struct YearReviewGraphView: View {
    @Binding var selectedSegment: Int
    var body: some View {
        Text("グラフが表示される")
        
        SegmentedControlButton(selectedSegment: $selectedSegment)
            .frame(width: 264, height: 56)
    }
}

#Preview {
    YearReviewGraphView(selectedSegment: .constant(0))
}
