//
//   MonthlyRecord.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/15.
//

import Foundation
import CoreData

@objc(MonthlyRecord)
public class MonthlyRecord: NSManagedObject {}

extension MonthlyRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonthlyRecord> {
        NSFetchRequest<MonthlyRecord>(entityName: "MonthlyRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var year: Int16
    @NSManaged public var month: Int16
    @NSManaged public var checkCount: Int16

    @NSManaged public var dailyRecords: Set<DailyRecord>?
}
