//
//  YearReviewView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/26.
//

import SwiftUI
import UIKit

struct YearReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var snapshotManager: SnapshotManager
    @StateObject private var recordService = DailyRecordService.shared
    
    @State private var showPopup = false
    @State private var selectedSegment: Int = 0
    @State private var selectedYear = 2025
    @State private var selectedMonth: Int? = nil
    @State private var currentMonth: Date = Date()
    @State private var showMonthReviewView = false
    @State private var isTapShareButton = false
    @State private var shareImage: UIImage? = nil
    @State private var captureRect: CGRect = .zero
    @State private var continuationDays: Int = 0
    @State private var monthlyCheckCounts: [Int: Int] = [:]
    
    @Binding var showDateReviewView: Bool
    
    var body: some View {
        ZStack {
            if showDateReviewView {
                DateReviewView(
                    showDateReviewView: $showDateReviewView,
                    currentMonth: $currentMonth,
                    reviewText: .constant(""),
                    selectedDateFromMonthReview: nil,
                    isFromAfterCheck: true  // AfterCheckViewからの遷移フラグ
                )
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
            
            if isTapShareButton {
                ShareView(
                   isTapShareButton: $isTapShareButton,
                   screenshot: shareImage,
                   continuationDays: continuationDays
                )
            }
        }
        .animation(.easeInOut, value: showMonthReviewView)
        .onAppear {
            // AfterCheckViewからの遷移時は今日の月に設定
            if showDateReviewView {
                setCurrentMonthToToday()
            }
            
            continuationDays = recordService.calculateContinuationDays(context: viewContext)
            
        }
        .onChange(of: showDateReviewView) { newValue in
            // DateReviewViewに遷移する時は今日の月に設定
            if newValue {
                setCurrentMonthToToday()
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    /// 今日の日付が属する月の1日に設定
    private func setCurrentMonthToToday() {
        let today = Date()
        let calendar = Calendar.current
        
        // 今日の年月を取得して、その月の1日に設定
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        
        if let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
            currentMonth = firstDayOfMonth
            selectedYear = year
            selectedMonth = month
        }
    }
}

extension YearReviewView {
    private var header: some View {
        
        
        HStack{
            Button(action: {
                showPopup = true
            }){
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

            Button(action: {
                shareImage = ScreenshotHelper.captureScreen(in: captureRect)
                continuationDays = recordService.calculateContinuationDays(context: viewContext)
                isTapShareButton = true
            }){
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity, alignment:
                                .trailing)
                }
            
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
                            // 選択した月の1日に設定
                            currentMonth = Calendar.current.date(
                                from: DateComponents(year: selectedYear, month: monthNumber, day: 1)
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
            VStack(spacing: 16) {
                header
                monthButton
            }
            SegmentedControlButton(selectedSegment: $selectedSegment)
                .frame(width: 264, height: 56)
                .padding(.top, 24)
        }
        .background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    // Add a little padding around the captured area
                    let rect = geo.frame(in: .global).insetBy(dx: -16, dy: -16)
                    captureRect = rect
                }
                return Color.clear
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.baseColor0)
    }
    
    
    
}
#Preview {
    YearReviewView(showDateReviewView: .constant(false))
}
