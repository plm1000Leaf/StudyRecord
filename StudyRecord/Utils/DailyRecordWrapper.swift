//
//  DailyRecordWrapper.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/28.
//

import Foundation
import CoreData
import Combine

final class DailyRecordWrapper: ObservableObject {
    @Published var record: DailyRecord

    init(record: DailyRecord) {
        self.record = record
    }

    func updateMaterial(_ material: Material, context: NSManagedObjectContext) {
        record.material = material
        do {
            try context.save()
            objectWillChange.send() // SwiftUIに通知
        } catch {
            print("教材の保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
