import XCTest
import CoreData
@testable import StudyRecord

final class DailyRecordServiceTests: XCTestCase {
    var core: TestCoreDataStack!
    var service: DailyRecordService!

    override func setUp() {
        super.setUp()
        core = TestCoreDataStack()
        service = DailyRecordService.shared
    }

    override func tearDown() {
        service = nil
        core = nil
        super.tearDown()
    }

    func test_SameDateReturnsSameRecord() throws {
        let cal = Calendar(identifier: .gregorian)
        let day = cal.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))

        let r1 = service.getRecord(for: day, context: core.context)
        try core.context.save()                 // ← 新規作成を確実に永続化
        let r2 = service.getRecord(for: day, context: core.context)

        XCTAssertEqual(r1.objectID, r2.objectID, "同じ日は同一レコードであるべき")

        // ほんとに1件だけか確認
        let end = cal.date(byAdding: .day, value: 1, to: day)!
        let req: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        req.predicate = NSPredicate(format: "date >= %@ AND date < %@", day as NSDate, end as NSDate)
        let results = try core.context.fetch(req)
        XCTAssertEqual(results.count, 1)
    }

    func test_ContinuationDaysIs2_WhenYesterdayAndTodayAreChecked() throws {
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        // 昨日・今日をチェック済みに
        service.loadRecord(for: yesterday, context: core.context)
        service.updateIsChecked(true, context: core.context)
        service.loadRecord(for: today, context: core.context)
        service.updateIsChecked(true, context: core.context)

        try core.context.save()

        let days = service.calculateContinuationDays(from: today, context: core.context)
        XCTAssertEqual(days, 2)
    }
}

