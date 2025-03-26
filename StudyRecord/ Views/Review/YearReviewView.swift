//
//  YearReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/26.
//

import SwiftUI

struct YearReviewView: View {
    @State private var showMonthReviewView = false
    @State private var showPopup = false
    var body: some View {
        ZStack {


            if !showMonthReviewView {
                if showPopup {
                    ZStack {

                        yearView
                            .transition(.move(edge: .leading))
                        MovePeriodPopup(showPopup: .constant(true), items: (2025...2036).map { "\($0)" })
                    }
                } else {
                    yearView
                        .transition(.move(edge: .leading))
                }
            } else {
                MonthReviewView(showMonthReviewView: $showMonthReviewView)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: showMonthReviewView)
    }
    }


extension YearReviewView {
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
    
    private var monthButton: some View {
        ForEach(0..<4, id: \.self) { rowIndex in
            HStack(spacing: 16){
                ForEach(0..<3, id: \.self) { columnIndex in
                    let monthNumber = rowIndex * 3 + columnIndex + 1
                    Button(action: {
                        withAnimation {
                            showMonthReviewView = true
                        }
                    }) {
                        ZStack{
                            Rectangle()
                                .frame(width: 104, height: 104)
                                .foregroundColor(.mainColor0)
                            Text("\(monthNumber)")
                                .foregroundColor(.white)
                                .font(.system(size: 32))
                                 .bold()
                        }
                    }
                }
            }
        }

    }
    
    private var segmentedControl: some View {
        Rectangle()
            .frame(width: 264, height: 48)
            .padding(.top, 24)
    }
    
    private var yearView: some View {
        VStack(spacing: 16) {
            header
            monthButton
            SegmentedControlButton()
                .frame(width: 264, height: 56)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.baseColor0)
    }
    
    
}
#Preview {
    YearReviewView()
}
