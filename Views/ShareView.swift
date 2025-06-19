//
//  ShareView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/16.
//

import SwiftUI
import CoreData

enum ShareSourceType {
    case yearReview(selectedYear: Int, monthlyCheckCounts: [Int: Int])
    case monthReview(currentMonth: Date)
    case afterCheck
}

struct ShareView: View {
    @Binding var isTapShareButton: Bool
    @State private var continuationDays: Int = 0
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    
    let sourceType: ShareSourceType
    
    init(isTapShareButton: Binding<Bool>, sourceType: ShareSourceType = .afterCheck) {
        self._isTapShareButton = isTapShareButton
        self.sourceType = sourceType
    }
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40){
                Button(action: {
                    isTapShareButton = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(32)
                        .padding(.bottom, -56)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                screenshotContent
                continuationResult
                shareButton
            }
        }
        .onAppear {
            loadContinuationDays()
        }
    }
}

extension ShareView {
    
    @ViewBuilder
    private var screenshotContent: some View {
        switch sourceType {
        case .yearReview(let selectedYear, let monthlyCheckCounts):
            yearReviewScreenshot(selectedYear: selectedYear, monthlyCheckCounts: monthlyCheckCounts)
        case .monthReview(let currentMonth):
            monthReviewScreenshot(currentMonth: currentMonth)
        case .afterCheck:
            Rectangle()
                .frame(width: 312, height: 400)
                .foregroundColor(.gray.opacity(0.3))
                .overlay(
                    Text("学習完了画面\nスクリーンショット")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                )
        }
    }
    
    // YearReviewViewのheaderとmonthButton部分のスクリーンショット
    private func yearReviewScreenshot(selectedYear: Int, monthlyCheckCounts: [Int: Int]) -> some View {
        VStack(spacing: 16) {
            // Header部分
            HStack{
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
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: 312, alignment: .leading)
            .foregroundColor(.gray10)
            
            // MonthButton部分
            ForEach(0..<4, id: \.self) { rowIndex in
                HStack(spacing: 16){
                    ForEach(0..<3, id: \.self) { columnIndex in
                        let monthNumber = rowIndex * 3 + columnIndex + 1
                        let checkCount = monthlyCheckCounts[monthNumber] ?? 0
                        let opacity = recordService.getColorOpacity(for: monthNumber, in: monthlyCheckCounts)
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 88, height: 88) // 少し小さくして画面に収める
                                .foregroundColor(.mainColor0.opacity(opacity))
                            Text("\(monthNumber)")
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                                .bold()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.baseColor0)
        .frame(width: 312, height: 400)
        .cornerRadius(12)
    }
    
    // MonthReviewViewのmonthView部分のスクリーンショット
    private func monthReviewScreenshot(currentMonth: Date) -> some View {
        VStack(spacing: 20) {
            // MonthReview用のヘッダー
            HStack(alignment: .bottom){
                Text(CalendarUtils.yearString(from: currentMonth))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    .font(.system(size: 16))
                    .padding(.leading, 16)
                
                Text(CalendarUtils.monthString(from: currentMonth))
                    .alignmentGuide(.bottom) { d in d[.firstTextBaseline] }
                    .font(.system(size: 40))
                    .padding(.leading, 8)
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .padding(.trailing, 16)
            }
            .frame(maxWidth: .infinity)
            
            // 簡略化されたカレンダー表示
            VStack(spacing: 12) {
                // 曜日ヘッダー
                HStack {
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // カレンダーの日付表示（簡略版）
                let days = CalendarUtils.generateCalendarDays(for: currentMonth)
                let chunkedDays = days.chunked(into: 7)
                
                ForEach(Array(chunkedDays.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 4) {
                        ForEach(week, id: \.self) { date in
                            if date > 0 {
                                VStack(spacing: 2) {
                                    Text("\(date)")
                                        .font(.caption2)
                                    Circle()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.mainColor0)
                                        .opacity(Bool.random() ? 1.0 : 0.3) // ダミーデータ
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Text("")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding()
        .background(Color.baseColor0)
        .frame(width: 312, height: 400)
        .cornerRadius(12)
    }
    
    private var continuationResult: some View {
        VStack{
            Text("継続日数")
                .font(.system(size: 32))
            Text("\(continuationDays)日")
                .font(.system(size: 40))
        }
        .foregroundColor(.white)
    }
    
    private var shareButton: some View {
        HStack(spacing: 24){
            Text("X")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 88, height: 88)
                .background(Color.black)
                .cornerRadius(12)
            
            Image(systemName: "camera")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 88, height: 88)
                .background(.purple)
                .cornerRadius(12)
            
            Image(systemName: "ellipsis")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 88, height: 88)
                .background(.notCheckedColor0)
                .cornerRadius(12)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Methods
    
    private func loadContinuationDays() {
        continuationDays = recordService.calculateContinuationDays(context: viewContext)
    }
}

// Array拡張：配列をチャンクに分割するヘルパー
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - プレビュー用
#Preview("AfterCheck ShareView") {
    ShareView(isTapShareButton: .constant(true), sourceType: .afterCheck)
}

#Preview("YearReview ShareView") {
    ShareView(
        isTapShareButton: .constant(true),
        sourceType: .yearReview(selectedYear: 2025, monthlyCheckCounts: [1: 15, 2: 20, 3: 25, 4: 18])
    )
}

#Preview("MonthReview ShareView") {
    ShareView(
        isTapShareButton: .constant(true),
        sourceType: .monthReview(currentMonth: Date())
    )
}
