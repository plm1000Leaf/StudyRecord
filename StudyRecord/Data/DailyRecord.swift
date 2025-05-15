//
//  DailyRecord.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/15.
//

import Foundation
import CoreData

@objc(DailyRecord)
public class DailyRecord: NSManagedObject {}

extension DailyRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyRecord> {
        return NSFetchRequest<DailyRecord>(entityName: "DailyRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var isChecked: Bool
    @NSManaged public var startPage: Int16
    @NSManaged public var endPage: Int16
    @NSManaged public var startUnit: String?
    @NSManaged public var endUnit: String?
    @NSManaged public var alarmOn: Bool
    @NSManaged public var isRepeating: Bool
    @NSManaged public var scheduledHour: Int16
    @NSManaged public var scheduledMinute: Int16

    // リレーション
    @NSManaged public var material: Material?
    @NSManaged public var monthlySummary: MonthlyRecord?
}

