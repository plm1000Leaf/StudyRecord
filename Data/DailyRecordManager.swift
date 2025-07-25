//
//  DailyRecordManager.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/17.
//
import Foundation
import CoreData

enum StudyRangeType {
    case start
    case end
}

final class DailyRecordManager {
    static let shared = DailyRecordManager()
    private init() {}

    func fetchOrCreateRecord(for date: Date, context: NSManagedObjectContext) -> DailyRecord {
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        request.fetchLimit = 1

        if let result = try? context.fetch(request).first {
            return result
        } else {
            let new = DailyRecord(context: context)
            new.date = date
            try? context.save()
            return new
        }
    }


    func updateReview(_ review: String, for record: DailyRecord, context: NSManagedObjectContext) {
        record.review = review
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateStartPage(_ startPage: String, for record: DailyRecord, context: NSManagedObjectContext) {
        record.startPage = startPage
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateEndPage(_ endPage: String, for record: DailyRecord, context: NSManagedObjectContext) {
        record.endPage = endPage
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateStartUnit(_ startUnit: String, for record: DailyRecord, context: NSManagedObjectContext) {
        record.startUnit = startUnit
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateEndUnit(_ endUnit: String, for record: DailyRecord, context: NSManagedObjectContext) {
        record.endUnit = endUnit
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateScheduledHour(_ scheduledHour: Int16, for record: DailyRecord, context: NSManagedObjectContext) {
        record.scheduledHour = scheduledHour
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateScheduledMinute(_ scheduledMinute: Int16, for record: DailyRecord, context: NSManagedObjectContext) {
        record.scheduledMinute = scheduledMinute
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateEventIdentifier(_ identifier: String?, for record: DailyRecord, context: NSManagedObjectContext) {
        record.eventIdentifier = identifier
        do {
            try context.save()
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }
    
    func updateIsChecked(_ isChecked: Bool, for record: DailyRecord, context: NSManagedObjectContext) {
        record.isChecked = isChecked
        
        do {
            try context.save()
            print("学習完了状態を更新しました: \(isChecked ? "完了" : "未完了")")
        } catch {
            print("学習完了状態の保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
}

