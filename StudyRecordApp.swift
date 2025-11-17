//
//  StudyRecordApp.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/18.
//

import SwiftUI

@main
struct StudyRecordApp: App {
    let persistenceController: PersistenceController
    @StateObject private var snapshotManager = SnapshotManager()
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE") {
            persistenceController = PersistenceController(inMemory: true)
        } else {
            persistenceController = PersistenceController.shared
        }
    }


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(snapshotManager)
        }
    }
}
