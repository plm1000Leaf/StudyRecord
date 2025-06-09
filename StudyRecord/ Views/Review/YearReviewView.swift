//
//  YearReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/26.
//

import SwiftUI

struct YearReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    
    @State private var showPopup = false
    @State private var selectedSegment: Int = 0
    @State private var selectedYear = 2025
    @State private var selectedMonth: Int? = nil
    @State private var currentMonth: Date = Date()
    @State private var showMonthReviewView = false
    @State private var monthlyCheckCounts: [Int: Int] = [:]
    
    @Binding var showDateReviewView: Bool
    
    var body: some View {
        ZStack {

            if showDateReviewView {
                DateReviewView(showDateReviewView: $showDateReviewView, currentMonth: $currentMonth, reviewText: .constant(""))
                    .transition(.move(edge: .trailing))
            } else if !showMonthReviewView {
                if showPopup {
                    yearView
                        .transition(.move(edge: .leading))
                } else {
                    if selectedSegment == 0 {
                        yearView
                            .transition(.move(edge: .leading))
                    } else {
                        YearReviewGraphView(selectedSegment: $selectedSegment)
                            .transition(.move(edge: .leading))
                    }
                }
            } else {
                MonthReviewView(showMonthReviewView:$showMonthReviewView, currentMonth: $currentMonth
                )
                    .transition(.move(edge: .trailing))
            }
            if showPopup {
                MovePeriodPopup(
                    showPopup: $showPopup,
                    items: (2025...2036).map { "\($0)" },
                    onSelect: { year in
                        selectedYear = year
                        showPopup = false
                    }
                )
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
                    Text(String(selectedYear))
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
        .padding(.top, 8)
        .padding(.bottom, 24)
        .frame(maxWidth: 312, alignment: .leading)
        .foregroundColor(.gray10)
    }
    
    private var monthButton: some View {
        ForEach(0..<4, id: \.self) { rowIndex in
            HStack(spacing: 16){
                ForEach(0..<3, id: \.self) { columnIndex in
                    let monthNumber = rowIndex * 3 + columnIndex + 1
                    let checkCount = monthlyCheckCounts[monthNumber] ?? 0
                    let opacity = recordService.getColorOpacity(for: monthNumber, in: monthlyCheckCounts)
                    
                    Button(action: {
                        withAnimation {
                            selectedMonth = monthNumber
                            currentMonth = Calendar.current.date(
                                from: DateComponents(year: selectedYear, month: monthNumber)
                            ) ?? Date()
                            showMonthReviewView = true
                        }
                    }) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 104, height: 104)
                                .foregroundColor(.mainColor0.opacity(opacity))
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
    
    
    private var yearView: some View {
        VStack(spacing: 16) {
            header
            monthButton
            
            SegmentedControlButton(selectedSegment: $selectedSegment)
                .frame(width: 264, height: 56)
                .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.baseColor0)
    }
    
    
}
#Preview {
    YearReviewView(showDateReviewView: .constant(false))
}
