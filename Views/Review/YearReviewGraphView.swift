//
//  YearReviewGraphView.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/03/14.
//

import SwiftUI
import UIKit

struct YearReviewGraphView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recordService = DailyRecordService.shared
    @Binding var selectedSegment: Int
    @Binding var selectedYear: Int
    @State private var showPopup = false
    @State private var isTapShareButton = false
    @State private var shareImage: UIImage? = nil
    @State private var captureRect: CGRect = .zero
    @State private var continuationDays: Int = 0
    @State private var yearlyCheckedDays: Int = 0
    
    var body: some View {
        ZStack{
            yearGraphView
            
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
                ShareView(isTapShareButton: $isTapShareButton, screenshot: shareImage,
                          continuationDays: continuationDays,
                          shareYear: selectedYear,
                          yearlyCheckedDays: yearlyCheckedDays)
            }
        }
        .onAppear {
            continuationDays = recordService.calculateContinuationDays(from: Date(), context: viewContext)
            loadYearlyCheckedDays(for: selectedYear)
        }
        .onChange(of: selectedYear) { newValue in
            loadYearlyCheckedDays(for: newValue)
        }
    }
}

extension YearReviewGraphView {
    private func loadYearlyCheckedDays(for year: Int) {
        let statistics = recordService.getYearlyStatistics(for: year, context: viewContext)
        yearlyCheckedDays = statistics.totalCheckedDays
    }

    private var yearGraphView: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                header

                YearReviewGraphWithYear(selectedYear: selectedYear)
                    .id(selectedYear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // グラフが画面全体を使用
            }
            .background(
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async { captureRect = geo.frame(in: .global) }
                    return Color.clear
                }
            )
            SegmentedControlButton(selectedSegment: $selectedSegment)
                .frame(width: 264, height: 48)  // ボタンの高さを少し縮小
                .padding(.bottom, 48)  // 下部余白を縮小
        }
        .background(Color.baseColor0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // 親コンテナも画面全体を使用
    }

    
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
            Button(action: {
                shareImage = ScreenshotHelper.captureScreen(in: captureRect)
                continuationDays = recordService.calculateContinuationDays(from: Date(), context: viewContext)
                isTapShareButton = true
                loadYearlyCheckedDays(for: selectedYear)
            }){
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 32))
                    .frame(maxWidth: .infinity, alignment:
                            .trailing)
                    .foregroundColor(.mainColor0)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .frame(maxWidth: 312, alignment: .leading)
        .foregroundColor(.gray10)
        }
    }
    
// MARK: - 年選択対応のグラフコンポーネント
struct YearReviewGraphWithYear: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var graphDataService = GraphDataService.shared
    
    let selectedYear: Int
    @State private var monthlyPercentages: [Double] = []
    
    let monthLabels: [String] = ["1月", "2月", "3月", "4月", "5月", "6月",
                                 "7月", "8月", "9月", "10月", "11月", "12月"]
    
    // Y軸の目盛り（0%, 25%, 50%, 75%, 100%）
    let yAxisLabels: [Int] = [0, 25, 50, 75, 100]
    let chartHeight: CGFloat = 280  // 高さを増加

    var body: some View {
        VStack(spacing: 0) {
            if monthlyPercentages.isEmpty {
                Text("データを読み込み中...")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                HStack(alignment: .bottom, spacing: 0) {
                    // Y軸（縦軸の目盛り）
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(yAxisLabels.reversed(), id: \.self) { percentage in
                            HStack {
                                Text("\(percentage)%")
                                    .font(.caption2)
                                    .foregroundColor(.gray30)
                                
                                // 目盛り線
                                Rectangle()
                                    .fill(Color.gray30.opacity(0.3))
                                    .frame(width: 4, height: 1)
                            }
                            .frame(height: chartHeight / CGFloat(yAxisLabels.count - 1))
                        }
                        
                        // X軸ラベル部分の空白
                        Spacer()
                            .frame(height: 50)
                    }
                    .frame(width: 45)
                    
                    // グラフエリア
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .bottom) {
                            // 背景のグリッド線
                            VStack(spacing: 0) {
                                ForEach(yAxisLabels.reversed().dropLast(), id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.gray30.opacity(0.1))
                                        .frame(height: 1)
                                    Spacer()
                                        .frame(height: chartHeight / CGFloat(yAxisLabels.count - 1) - 1)
                                }
                            }
                            .frame(height: chartHeight)
                            
                            // 棒グラフ
                            HStack(alignment: .bottom, spacing: 12) {  // 棒の間隔を広げる
                                ForEach(monthlyPercentages.indices, id: \.self) { index in
                                    VStack(spacing: 6) {
                                        // パーセンテージ表示
                                        Text("\(Int(monthlyPercentages[index]))%")
                                            .font(.caption)
                                            .foregroundColor(.gray0)
                                            .padding(.bottom, 4)
                                        
                                        // 棒グラフ
                                        Rectangle()
                                            .foregroundColor(.mainColor0)
                                            .frame(width: 32, height: CGFloat(monthlyPercentages[index] / 100.0 * chartHeight))  // 棒の幅を増加
                                            .cornerRadius(4)
                                        
                                        // 月ラベル
                                        Text(monthLabels[index])
                                            .font(.system(size: 14))  // フォントサイズを増加
                                            .foregroundColor(.gray0)
                                            .frame(width: 32)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 48)
                        }
                    }
                }
                .frame(height: chartHeight + 80) // 高さを増加
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // 画面全体を使用
        .padding(.horizontal, 16)  // 左右の余白を調整
        .onAppear {
            loadMonthlyPercentages()
        }
        .onChange(of: selectedYear) { _ in
            loadMonthlyPercentages()
        }
    }
    
    // MARK: - Private Methods
    
    /// 月ごとの完了率を計算
    private func loadMonthlyPercentages() {
        monthlyPercentages = graphDataService.loadMonthlyPercentages(for: selectedYear, context: viewContext)
    }
}


