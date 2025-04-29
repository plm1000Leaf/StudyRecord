//
//  YearReviewGraphView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/14.
//

import SwiftUI

struct YearReviewGraphView: View {
    @Binding var selectedSegment: Int
    @State private var showPopup = false
    
    var body: some View {
        ZStack{
            yearGraphView
        }
    }
}

extension YearReviewGraphView {
    private var header: some View {
        
        
        HStack{
            Button(action: {showPopup = true }){
                HStack(alignment: .bottom){
                    Text("2025")
                        .font(.system(size: 48))
                        .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    Spacer()
                        .frame(width: 8)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16))
                        .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                }
            }
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment:
                        .trailing)
        }
        .padding(.top, 48)
        .padding(.bottom, 40)
        .frame(maxWidth: 312, alignment: .leading)
        .foregroundColor(.gray10)
    }
    
    private var yearGraphView: some View {
        VStack{
            header
            
            YearReviewGraph()
            
            SegmentedControlButton(selectedSegment: $selectedSegment)
                .frame(width: 264, height: 56)
                .padding(.bottom, 13)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .background(Color.baseColor0)
    }
}
#Preview {
    YearReviewGraphView(selectedSegment: .constant(0))
}
