//
//  YearReviewGraph.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/08.
//

import SwiftUI
import CoreData

struct YearReviewGraph: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var graphDataService = GraphDataService.shared
    
    @State private var monthlyPercentages: [Double] = []
    
    // 外部から年を受け取るプロパティ
    let selectedYear: Int
    
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
    
    /// 月ごとの学習完了率を計算
    private func loadMonthlyPercentages() {
        monthlyPercentages = graphDataService.loadMonthlyPercentages(for: selectedYear, context: viewContext)
    }
}

// MARK: - Preview
#Preview {
    YearReviewGraph(selectedYear: 2025)
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
