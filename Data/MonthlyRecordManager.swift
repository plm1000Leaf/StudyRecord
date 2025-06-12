
//
//  MonthlyRecordManager.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/06/09.
//

import Foundation
import CoreData

/// MonthlyRecordの管理を担当するマネージャークラス
final class MonthlyRecordManager {
    static let shared = MonthlyRecordManager()
    private init() {}
    
    // MARK: - Core CRUD Operations
    
    /// 月次レコードを取得または作成
    func fetchOrCreateRecord(for date: Date, context: NSManagedObjectContext) -> MonthlyRecord {
        let calendar = Calendar.current
        let year = Int16(calendar.component(.year, from: date))
        let month = Int16(calendar.component(.month, from: date))
        
        let request: NSFetchRequest<MonthlyRecord> = MonthlyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "year == %d AND month == %d", year, month)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            return existing
        } else {
            let new = MonthlyRecord(context: context)
            new.id = UUID()
            new.year = year
            new.month = month
            new.checkCount = 0
            try? context.save()
            return new
        }
    }
    
    /// 指定した年のすべての月次レコードを取得
    func fetchRecordsForYear(_ year: Int, context: NSManagedObjectContext) -> [MonthlyRecord] {
        let request: NSFetchRequest<MonthlyRecord> = MonthlyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "year == %d", year)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MonthlyRecord.month, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("MonthlyRecord年間取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 指定した年月の月次レコードを取得
    func fetchRecord(for year: Int, month: Int, context: NSManagedObjectContext) -> MonthlyRecord? {
        let request: NSFetchRequest<MonthlyRecord> = MonthlyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "year == %d AND month == %d", year, month)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    // MARK: - Check Count Management
    
    /// 月次レコードのチェック数を実際のDailyRecordから再計算して更新
    func updateCheckCount(for date: Date, context: NSManagedObjectContext) {
        let monthlyRecord = fetchOrCreateRecord(for: date, context: context)
        let actualCheckCount = calculateActualCheckCount(for: date, context: context)
        
        monthlyRecord.checkCount = Int16(actualCheckCount)
        
        do {
            try context.save()
            print("MonthlyRecord更新完了: \(Calendar.current.component(.year, from: date))年\(Calendar.current.component(.month, from: date))月 - \(actualCheckCount)日")
        } catch {
            print("MonthlyRecord保存エラー: \(error.localizedDescription)")
        }
    }
    
    /// 指定した日付の月における実際のチェック数を計算
    private func calculateActualCheckCount(for date: Date, context: NSManagedObjectContext) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        
        var checkCount = 0
        
        for day in 1...numberOfDays {
            if let dayDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let dailyRecord = DailyRecordManager.shared.fetchOrCreateRecord(for: dayDate, context: context)
                if dailyRecord.isChecked {
                    checkCount += 1
                }
            }
        }
        
        return checkCount
    }
    
    /// 年間の月別チェック数を効率的に取得
    func getMonthlyCheckCounts(for year: Int, context: NSManagedObjectContext) -> [Int: Int] {
        let monthlyRecords = fetchRecordsForYear(year, context: context)
        var counts: [Int: Int] = [:]
        
        // 既存のMonthlyRecordから取得
        for record in monthlyRecords {
            counts[Int(record.month)] = Int(record.checkCount)
        }
        
        // 存在しない月は0で初期化
        for month in 1...12 {
            if counts[month] == nil {
                counts[month] = 0
                // 必要に応じて空のMonthlyRecordを作成
                if let monthDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
                    _ = fetchOrCreateRecord(for: monthDate, context: context)
                }
            }
        }
        
        return counts
    }
    
    // MARK: - Batch Operations
    
    /// 指定した年のすべての月のチェック数を再計算
    func recalculateAllCheckCounts(for year: Int, context: NSManagedObjectContext) {
        for month in 1...12 {
            if let monthDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
                updateCheckCount(for: monthDate, context: context)
            }
        }
    }
    
    /// データベースの整合性チェック
    func validateData(for year: Int, context: NSManagedObjectContext) -> Bool {
        let monthlyRecords = fetchRecordsForYear(year, context: context)
        
        for record in monthlyRecords {
            let year = Int(record.year)
            let month = Int(record.month)
            
            guard let monthDate = Calendar.current.date(from: DateComponents(year: year, month: month)) else {
                continue
            }
            
            let actualCount = calculateActualCheckCount(for: monthDate, context: context)
            let storedCount = Int(record.checkCount)
            
            if actualCount != storedCount {
                print("データ不整合発見: \(year)年\(month)月 - 実際:\(actualCount), 保存:\(storedCount)")
                return false
            }
        }
        
        return true
    }
    
    /// データ不整合を修復
    func repairDataInconsistency(for year: Int, context: NSManagedObjectContext) {
        print("データ修復開始: \(year)年")
        recalculateAllCheckCounts(for: year, context: context)
        print("データ修復完了: \(year)年")
    }
    
    // MARK: - Statistics
    
    /// 年間統計情報を取得
    func getYearlyStatistics(for year: Int, context: NSManagedObjectContext) -> YearlyStatistics {
        let monthlyCheckCounts = getMonthlyCheckCounts(for: year, context: context)
        
        let totalDays = monthlyCheckCounts.values.reduce(0, +)
        let averagePerMonth = totalDays / 12
        let maxMonth = monthlyCheckCounts.max(by: { $0.value < $1.value })
        let minMonth = monthlyCheckCounts.min(by: { $0.value < $1.value })
        
        return YearlyStatistics(
            year: year,
            totalCheckedDays: totalDays,
            averagePerMonth: averagePerMonth,
            bestMonth: maxMonth?.key,
            bestMonthDays: maxMonth?.value ?? 0,
            worstMonth: minMonth?.key,
            worstMonthDays: minMonth?.value ?? 0,
            monthlyData: monthlyCheckCounts
        )
    }
}

// MARK: - Data Structures

/// 年間統計情報
struct YearlyStatistics {
    let year: Int
    let totalCheckedDays: Int
    let averagePerMonth: Int
    let bestMonth: Int?
    let bestMonthDays: Int
    let worstMonth: Int?
    let worstMonthDays: Int
    let monthlyData: [Int: Int]
}

// MARK: - Extensions

extension MonthlyRecordManager {
    /// デバッグ用：指定した年の全データを出力
    func debugPrintYearData(for year: Int, context: NSManagedObjectContext) {
        print("=== MonthlyRecord Debug: \(year)年 ===")
        let statistics = getYearlyStatistics(for: year, context: context)
        
        print("年間合計: \(statistics.totalCheckedDays)日")
        print("月平均: \(statistics.averagePerMonth)日")
        
        if let bestMonth = statistics.bestMonth {
            print("最高月: \(bestMonth)月 (\(statistics.bestMonthDays)日)")
        }
        
        if let worstMonth = statistics.worstMonth {
            print("最低月: \(worstMonth)月 (\(statistics.worstMonthDays)日)")
        }
        
        print("月別データ:")
        for month in 1...12 {
            let count = statistics.monthlyData[month] ?? 0
            print("  \(month)月: \(count)日")
        }
        
        print("================================")
    }
}
