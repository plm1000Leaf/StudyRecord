//
//  DailyRecordService.swift
//  StudyRecord
//
//  MonthlyRecordManager分離版：責任を明確化
//

import Foundation
import CoreData
import Combine

/// 日付ごとのデータを一元管理するサービスクラス
final class DailyRecordService: ObservableObject {
    static let shared = DailyRecordService()
    
    // MARK: - Published Properties
    @Published var currentRecord: DailyRecord?
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let dailyManager = DailyRecordManager.shared
    private let monthlyManager = MonthlyRecordManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    /// シングルトン用のプライベートイニシャライザ
    private init() {}
    
    /// インスタンス作成用のパブリックイニシャライザ
    convenience init(independent: Bool = true) {
        self.init()
    }
    
    // MARK: - Efficient Monthly Check Count Methods
    
    /// MonthlyRecordManagerを使用して効率的に年間チェック数を取得
    func loadMonthlyCheckCountsFromMonthlyRecord(for year: Int, context: NSManagedObjectContext) -> [Int: Int] {
        return monthlyManager.getMonthlyCheckCounts(for: year, context: context)
    }
    
    /// 指定した年の月別チェック数を取得（フォールバック用）
    func loadMonthlyCheckCounts(for year: Int, context: NSManagedObjectContext) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        
        for month in 1...12 {
            if let monthDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
                let checkedCount = getCheckedCountForMonth(monthDate, context: context)
                counts[month] = checkedCount
            }
        }
        
        return counts
    }
    
    func loadMonthlyCheckRatesFromMonthlyRecord(for year: Int, context: NSManagedObjectContext) -> [Int: Double] {
        let request: NSFetchRequest<MonthlyRecord> = MonthlyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "year == %d", year)
        
        do {
            let monthlyRecords = try context.fetch(request)
            var monthlyRates: [Int: Double] = [:]
            
            for record in monthlyRecords {
                let totalDays = record.checkCount
                let checkedDays = record.checkCount
                
                if totalDays > 0 {
                    let rate = Double(checkedDays) / Double(totalDays) * 100.0
                    monthlyRates[Int(record.month)] = rate
                } else {
                    monthlyRates[Int(record.month)] = 0.0
                }
            }
            
            return monthlyRates
        } catch {
            print("❌ 月別記録の読み込みに失敗: \(error)")
            return [:]
        }
    }
    
    
    /// 指定した月のチェック数を取得
    func getCheckedCountForMonth(_ month: Date, context: NSManagedObjectContext) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let monthNum = calendar.component(.month, from: month)
        let numberOfDays = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        
        var checkedCount = 0
        
        for day in 1...numberOfDays {
            if let date = calendar.date(from: DateComponents(year: year, month: monthNum, day: day)) {
                let record = dailyManager.fetchOrCreateRecord(for: date, context: context)
                if record.isChecked {
                    checkedCount += 1
                }
            }
        }
        
        return checkedCount
    }
    
    /// 月別チェック数に基づいて色の濃度を計算
    func getColorOpacity(for month: Int, in monthlyCheckCounts: [Int: Int]) -> Double {
        let checkCount = monthlyCheckCounts[month] ?? 0
        let maxCount = monthlyCheckCounts.values.max() ?? 1
        
        if maxCount == 0 {
            return 0.3 // 最低限の濃度
        }
        
        let ratio = Double(checkCount) / Double(maxCount)
        return 0.3 + (ratio * 0.7) // 0.3 〜 1.0 の範囲
    }
    
    /// 年間統計情報を取得
    func getYearlyStatistics(for year: Int, context: NSManagedObjectContext) -> YearlyStatistics {
        return monthlyManager.getYearlyStatistics(for: year, context: context)
    }
    
    
    
    // MARK: - Public Methods
    
    /// 指定した日付のレコードを取得
    func loadRecord(for date: Date, context: NSManagedObjectContext) {
        isLoading = true
        currentRecord = dailyManager.fetchOrCreateRecord(for: date, context: context)
        isLoading = false
    }
    
    /// 複数日付のレコードを一括取得
    func loadRecordsForMonth(_ month: Date, context: NSManagedObjectContext) -> [DailyRecord] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        let range = calendar.range(of: .day, in: .month, for: month) ?? 1..<2
        
        var records: [DailyRecord] = []
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let record = dailyManager.fetchOrCreateRecord(for: date, context: context)
                records.append(record)
            }
        }
        return records
    }
    
    func loadCheckedDates(for month: Date, context: NSManagedObjectContext) -> [Int: Bool] {
         let calendar = Calendar.current
         let year = calendar.component(.year, from: month)
         let monthNum = calendar.component(.month, from: month)
         let numberOfDays = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
         
         var checkedDates: [Int: Bool] = [:]
         
         for day in 1...numberOfDays {
             if let date = calendar.date(from: DateComponents(year: year, month: monthNum, day: day)) {
                 let record = dailyManager.fetchOrCreateRecord(for: date, context: context)
                 checkedDates[day] = record.isChecked
             }
         }
         
         return checkedDates
     }
    
    
    

    /// 今日のレコードを取得
    func loadTodayRecord(context: NSManagedObjectContext) {
        let today = Calendar.current.startOfDay(for: Date())
        loadRecord(for: today, context: context)
    }
    
    // DailyRecordService内に追加
    func hasScheduledTime() -> Bool {
        let (hour, minute) = getScheduledTime()
        // デフォルト値（例：0時0分）と異なる場合は設定済みとみなす
        return !(hour == 0 && minute == 0)
    }

    
    // MARK: - Study Range Methods
    
    /// 学習範囲（開始）を更新
    func updateStartPage(_ startPage: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateStartPage(startPage, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習範囲（終了）を更新
    func updateEndPage(_ endPage: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateEndPage(endPage, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習単位（開始）を更新
    func updateStartUnit(_ startUnit: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateStartUnit(startUnit, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習単位（終了）を更新
    func updateEndUnit(_ endUnit: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateEndUnit(endUnit, for: record, context: context)
        objectWillChange.send()
    }
    
    // MARK: - Material Methods
    
    /// 教材を更新
    func updateMaterial(_ material: Material, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        record.material = material
        do {
            try context.save()
            objectWillChange.send()
        } catch {
            print("教材の保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Schedule Methods
    
    /// 予定時間（時）を更新
    func updateScheduledHour(_ hour: Int16, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateScheduledHour(hour, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 予定時間（分）を更新
    func updateScheduledMinute(_ minute: Int16, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateScheduledMinute(minute, for: record, context: context)
        objectWillChange.send()
    }
    
    // MARK: - Review Methods
    
    /// 振り返りを更新
    func updateReview(_ review: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        dailyManager.updateReview(review, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習完了状態を更新（MonthlyRecordも同時更新）
    func updateIsChecked(_ isChecked: Bool, context: NSManagedObjectContext) {
        guard let record = currentRecord else {
            print("更新対象のレコードがありません")
            return
        }
        
        // DailyRecordを更新
        dailyManager.updateIsChecked(isChecked, for: record, context: context)
        
        // MonthlyRecordのチェック数も更新
        if let date = record.date {
            monthlyManager.updateCheckCount(for: date, context: context)
        }
        
        objectWillChange.send()
    }
    
    // MARK: - Getter Methods
    
    /// 現在のレコードの学習範囲情報を取得
    func getStudyRange() -> (startPage: String, endPage: String, startUnit: String, endUnit: String) {
        guard let record = currentRecord else {
            return ("", "", "", "")
        }
        return (
            startPage: record.startPage ?? "",
            endPage: record.endPage ?? "",
            startUnit: record.startUnit ?? "",
            endUnit: record.endUnit ?? ""
        )
    }
    
    /// 現在のレコードの教材情報を取得
    func getMaterial() -> Material? {
        return currentRecord?.material
    }
    
    /// 現在のレコードの予定時間を取得
    func getScheduledTime() -> (hour: Int16, minute: Int16) {
        guard let record = currentRecord else {
            return (12, 30) // デフォルト値
        }
        return (hour: record.scheduledHour, minute: record.scheduledMinute)
    }
    
    /// 現在のレコードの振り返りを取得
    func getReview() -> String {
        return currentRecord?.review ?? ""
    }
    
    /// フォーマットされた時間文字列を取得
    func getFormattedTime() -> String {
        let (hour, minute) = getScheduledTime()
        return String(format: "%02d:%02d", hour, minute)
    }
    
    // MARK: - Batch Operations
    
    /// 指定した日付のレコードを直接取得（現在のレコードを変更しない）
    func getRecord(for date: Date, context: NSManagedObjectContext) -> DailyRecord {
        return dailyManager.fetchOrCreateRecord(for: date, context: context)
    }
    
    /// 現在の学習完了状態を取得
    func getIsChecked() -> Bool {
        return currentRecord?.isChecked ?? false
    }
    
    /// 現在日から遡って連続学習日数を計算
    func calculateContinuationDays(from date: Date = Date(), context: NSManagedObjectContext) -> Int {
        let calendar = Calendar.current
        var continuationDays = 0
        var currentDate = calendar.startOfDay(for: date)
        
        // 今日から過去に向かって連続学習日をカウント
        while true {
            let record = dailyManager.fetchOrCreateRecord(for: currentDate, context: context)
            
            if record.isChecked {
                continuationDays += 1
                // 前日に移動
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                // 学習していない日があったら終了
                break
            }
        }
        
        return continuationDays
    }
    /// 最大継続日数を計算（過去の記録から）
        func calculateMaxContinuationDays(context: NSManagedObjectContext) -> Int {
            // すべてのDailyRecordを日付順で取得
            let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: true)]
            
            guard let allRecords = try? context.fetch(request) else {
                return 0
            }
            
            var maxContinuation = 0
            var currentContinuation = 0
            
            // 連続する日付をチェック
            var previousDate: Date?
            
            for record in allRecords {
                guard let recordDate = record.date else { continue }
                
                if record.isChecked {
                    // 前の日と連続している場合
                    if let prevDate = previousDate,
                       Calendar.current.dateInterval(of: .day, for: prevDate)?.end == Calendar.current.dateInterval(of: .day, for: recordDate)?.start {
                        currentContinuation += 1
                    } else {
                        // 新しい連続開始
                        currentContinuation = 1
                    }
                    
                    maxContinuation = max(maxContinuation, currentContinuation)
                } else {
                    currentContinuation = 0
                }
                
                previousDate = recordDate
            }
            
            return maxContinuation
        }
        
        /// 継続日数の統計情報を取得
        func getContinuationStatistics(context: NSManagedObjectContext) -> ContinuationStatistics {
            let current = calculateContinuationDays(context: context)
            let max = calculateMaxContinuationDays(context: context)
            
            return ContinuationStatistics(
                currentContinuation: current,
                maxContinuation: max,
                isNewRecord: current > 0 && current == max
            )
        }

    // MARK: - Data Integrity Methods
    
    /// データ整合性をチェック
    func validateDataIntegrity(for year: Int, context: NSManagedObjectContext) -> Bool {
        return monthlyManager.validateData(for: year, context: context)
    }
    
    /// データ不整合を修復
    func repairDataInconsistency(for year: Int, context: NSManagedObjectContext) {
        monthlyManager.repairDataInconsistency(for: year, context: context)
    }
    
}

// MARK: - StudyRangeData Structure
/// View用のデータ構造体
struct StudyRangeData {
    let startPage: String
    let endPage: String
    let startUnit: String
    let endUnit: String
    let material: Material?
    let scheduledHour: Int16
    let scheduledMinute: Int16
    let review: String?
    let date: Date
    let isChecked: Bool
    
    init(from record: DailyRecord) {
        self.startPage = record.startPage ?? ""
        self.endPage = record.endPage ?? ""
        self.startUnit = record.startUnit ?? ""
        self.endUnit = record.endUnit ?? ""
        self.material = record.material
        self.scheduledHour = record.scheduledHour
        self.scheduledMinute = record.scheduledMinute
        self.review = record.review
        self.date = record.date ?? Date()
        self.isChecked = record.isChecked
    }
}

// 継続日数統計情報の構造体
struct ContinuationStatistics {
    let currentContinuation: Int
    let maxContinuation: Int
    let isNewRecord: Bool
}

// MARK: - Extensions
extension DailyRecordService {
    /// 現在のレコードのデータ構造体を取得
    func getCurrentStudyRangeData() -> StudyRangeData? {
        guard let record = currentRecord else { return nil }
        return StudyRangeData(from: record)
    }
    
    /// 指定した日付のデータ構造体を取得
    func getStudyRangeData(for date: Date, context: NSManagedObjectContext) -> StudyRangeData {
        let record = getRecord(for: date, context: context)
        return StudyRangeData(from: record)
    }
    
    /// デバッグ用: 現在の状態を出力
    func debugCurrentState() {
        print("=== DailyRecordService Debug ===")
        print("現在のレコード: \(currentRecord?.description ?? "nil")")
        if let record = currentRecord {
            print("日付: \(record.date?.formatted() ?? "不明")")
            print("学習範囲: \(getStudyRange())")
            print("教材: \(getMaterial()?.name ?? "未設定")")
            print("予定時間: \(getFormattedTime())")
        }
        print("================================")
    }
    
    /// デバッグ用: 年間データを出力
    func debugYearData(for year: Int, context: NSManagedObjectContext) {
        monthlyManager.debugPrintYearData(for: year, context: context)
    }
}
