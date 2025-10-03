//
//  TestCoreDataStack.swift
//  StudyRecordTests
//
//  Created by 千葉陽乃 on 2025/10/03.
//

import CoreData
final class TestCoreDataStack {
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    // ★ ここをプロジェクトの .xcdatamodeld と同じ名前にする
    init(modelName: String = "StudyRecordModel") {
        container = NSPersistentContainer(name: modelName)

        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData load error: \(error)") }
        }

        // ついでに“本当にDailyRecordがあるか”を自己診断
        #if DEBUG
        assert(self.container.managedObjectModel.entitiesByName["DailyRecord"] != nil,
               "DailyRecord entity not found in model \(modelName). Check the model name!")
        #endif
    }
}
