//
//  YearReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/26.
//

import SwiftUI

struct YearReviewView: View {
    @State private var showMonthReviewView = false
    
    var body: some View {
        ZStack {
            if !showMonthReviewView {
                yearView
                    .transition(.move(edge: .leading))
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
                    Button(action: {
                        withAnimation {
                            showMonthReviewView = true
                        }
                    }) {
                        Rectangle()
                            .frame(width: 104, height: 104)
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
            segmentedControl
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    
}
#Preview {
    YearReviewView()
}
