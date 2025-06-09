//
//  DailyRecordService.swift
//  StudyRecord
//
//  修正版：インスタンス作成を可能にする
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
    private let manager = DailyRecordManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    /// シングルトン用のプライベートイニシャライザ
    private init() {}
    
    /// インスタンス作成用のパブリックイニシャライザ
    /// - Parameter useShared: trueの場合はsharedインスタンスと同じ、falseの場合は独立したインスタンス
    convenience init(independent: Bool = true) {
        self.init()
        // 独立したインスタンスの場合は特別な処理は不要
        // 必要に応じて初期化処理をここに追加
    }
    
    // MARK: - Public Methods
    
    /// 指定した日付のレコードを取得
    func loadRecord(for date: Date, context: NSManagedObjectContext) {
        isLoading = true
        currentRecord = manager.fetchOrCreateRecord(for: date, context: context)
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
                let record = manager.fetchOrCreateRecord(for: date, context: context)
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
                 let record = manager.fetchOrCreateRecord(for: date, context: context)
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
    
    
    // MARK: - Study Range Methods
    
    /// 学習範囲（開始）を更新
    func updateStartPage(_ startPage: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateStartPage(startPage, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習範囲（終了）を更新
    func updateEndPage(_ endPage: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateEndPage(endPage, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習単位（開始）を更新
    func updateStartUnit(_ startUnit: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateStartUnit(startUnit, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習単位（終了）を更新
    func updateEndUnit(_ endUnit: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateEndUnit(endUnit, for: record, context: context)
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
        manager.updateScheduledHour(hour, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 予定時間（分）を更新
    func updateScheduledMinute(_ minute: Int16, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateScheduledMinute(minute, for: record, context: context)
        objectWillChange.send()
    }
    
    // MARK: - Review Methods
    
    /// 振り返りを更新
    func updateReview(_ review: String, context: NSManagedObjectContext) {
        guard let record = currentRecord else { return }
        manager.updateReview(review, for: record, context: context)
        objectWillChange.send()
    }
    
    /// 学習完了状態を更新
    func updateIsChecked(_ isChecked: Bool, context: NSManagedObjectContext) {
        guard let record = currentRecord else {
            print("更新対象のレコードがありません")
            return
        }
        
        manager.updateIsChecked(isChecked, for: record, context: context)
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
        return manager.fetchOrCreateRecord(for: date, context: context)
    }
    
    /// 現在の学習完了状態を取得
    func getIsChecked() -> Bool {
        return currentRecord?.isChecked ?? false
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
}
