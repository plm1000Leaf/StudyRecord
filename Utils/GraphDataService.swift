//
//  GraphDataService.swift
//  StudyRecord
//
//  Created by システム on 2025/06/13.
//

import Foundation
import CoreData

/// グラフ表示用のデータを管理するサービスクラス
final class GraphDataService : ObservableObject{
    static let shared = GraphDataService()
    
    private let dailyManager = DailyRecordManager.shared
    
    private init() {}
    
    // MARK: - Monthly Percentage Methods
    
    /// 指定した年の月ごとの学習完了率を取得
    func loadMonthlyPercentages(for year: Int, context: NSManagedObjectContext) -> [Double] {
        var percentages: [Double] = []
        
        for month in 1...12 {
            let percentage = calculateMonthlyPercentage(year: year, month: month, context: context)
            percentages.append(percentage)
        }
        
        return percentages
    }
    
    /// 指定した年月の学習完了率を計算
    func calculateMonthlyPercentage(year: Int, month: Int, context: NSManagedObjectContext) -> Double {
        let calendar = Calendar.current
        
        // 指定した年月の日数を取得
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: month)),
              let numberOfDays = calendar.range(of: .day, in: .month, for: monthDate)?.count else {
            return 0.0
        }
        
        // 学習完了日数をカウント
        var checkedDays = 0
        
        for day in 1...numberOfDays {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let record = dailyManager.fetchOrCreateRecord(for: date, context: context)
                if record.isChecked {
                    checkedDays += 1
                }
            }
        }
        
        // 割合を計算（0-100%）
        let percentage = Double(checkedDays) / Double(numberOfDays) * 100.0
        return percentage
    }
    
    // MARK: - Statistics Methods
    
    /// 年間統計データを取得
    func getYearlyGraphStatistics(for year: Int, context: NSManagedObjectContext) -> YearlyGraphStatistics {
        let monthlyPercentages = loadMonthlyPercentages(for: year, context: context)
        
        let averagePercentage = monthlyPercentages.reduce(0, +) / Double(monthlyPercentages.count)
        let maxPercentage = monthlyPercentages.max() ?? 0.0
        let minPercentage = monthlyPercentages.min() ?? 0.0
        
        let bestMonthIndex = monthlyPercentages.firstIndex(of: maxPercentage) ?? 0
        let worstMonthIndex = monthlyPercentages.firstIndex(of: minPercentage) ?? 0
        
        return YearlyGraphStatistics(
            year: year,
            monthlyPercentages: monthlyPercentages,
            averagePercentage: averagePercentage,
            maxPercentage: maxPercentage,
            minPercentage: minPercentage,
            bestMonth: bestMonthIndex + 1, // 1ベースに変換
            worstMonth: worstMonthIndex + 1 // 1ベースに変換
        )
    }
    
    /// 複数年のデータを比較用に取得
    func loadMultiYearPercentages(years: [Int], context: NSManagedObjectContext) -> [Int: [Double]] {
        var result: [Int: [Double]] = [:]
        
        for year in years {
            result[year] = loadMonthlyPercentages(for: year, context: context)
        }
        
        return result
    }
    
    // MARK: - Cache Methods (将来の最適化用)
    
    private var percentageCache: [String: [Double]] = [:]
    
    /// キャッシュを使用した高速な月次データ取得
    func loadMonthlyPercentagesWithCache(for year: Int, context: NSManagedObjectContext) -> [Double] {
        let cacheKey = "\(year)"
        
        if let cachedData = percentageCache[cacheKey] {
            return cachedData
        }
        
        let percentages = loadMonthlyPercentages(for: year, context: context)
        percentageCache[cacheKey] = percentages
        
        return percentages
    }
    
    /// キャッシュをクリア
    func clearCache() {
        percentageCache.removeAll()
    }
    
    /// 特定年のキャッシュをクリア
    func clearCache(for year: Int) {
        let cacheKey = "\(year)"
        percentageCache.removeValue(forKey: cacheKey)
    }
}

// MARK: - Data Structures

/// 年間グラフ統計情報
struct YearlyGraphStatistics {
    let year: Int
    let monthlyPercentages: [Double]
    let averagePercentage: Double
    let maxPercentage: Double
    let minPercentage: Double
    let bestMonth: Int
    let worstMonth: Int
}

// MARK: - Extensions

extension GraphDataService {
    /// デバッグ用：指定した年のグラフデータを出力
    func debugPrintGraphData(for year: Int, context: NSManagedObjectContext) {
        print("=== GraphDataService Debug: \(year)年 ===")
        let statistics = getYearlyGraphStatistics(for: year, context: context)
        
        print("年間平均: \(String(format: "%.1f", statistics.averagePercentage))%")
        print("最高月: \(statistics.bestMonth)月 (\(String(format: "%.1f", statistics.maxPercentage))%)")
        print("最低月: \(statistics.worstMonth)月 (\(String(format: "%.1f", statistics.minPercentage))%)")
        
        print("月別データ:")
        for (index, percentage) in statistics.monthlyPercentages.enumerated() {
            print("  \(index + 1)月: \(String(format: "%.1f", percentage))%")
        }
        
        print("=======================================")
    }
}
