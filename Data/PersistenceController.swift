//
//  PersistenceController.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/05/15.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "StudyRecordModel") // ここは .xcdatamodeld の名前
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}

#if DEBUG
extension PersistenceController {
    /// プレビューやテストで使用するメモリ上の永続化コンテナ
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        DailyRecordService.shared.markRandomCheckedDays(monthsBack: 6,
                                                        countRange: 5...15,
                                                        context: context)

        return controller
    }()

    /// デモ用にランダムな日付を学習済みに設定
    /// - Parameters:
    ///   - monthsBack: 現在の月から遡る月数（現在の月を含む）
    ///   - countRange: 各月で学習済みにする日数の範囲
    ///   - context: 使用するコンテキスト（省略時は `viewContext`）
    ///   - calendar: 使用するカレンダー（省略時は `.current`）
    /// - Returns: 学習済みに設定された日付一覧
    @discardableResult
    func seedRandomCheckedDays(monthsBack: Int = 6,
                               countRange: ClosedRange<Int> = 5...15,
                               context: NSManagedObjectContext? = nil,
                               calendar: Calendar = .current) -> [Date] {
        let workingContext = context ?? container.viewContext
        return DailyRecordService.shared.markRandomCheckedDays(monthsBack: monthsBack,
                                                               countRange: countRange,
                                                               context: workingContext,
                                                               calendar: calendar)
    }
}
#endif
