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
        let arguments = ProcessInfo.processInfo.arguments
        let shouldSeed2025 = arguments.contains("SEED_2025_CHECKS")

        if arguments.contains("UI_TEST_MODE") {
            persistenceController = PersistenceController(inMemory: true,
                                                          seedYearForChecks: shouldSeed2025 ? 2025 : nil)
        } else {
            persistenceController = shouldSeed2025
                ? PersistenceController(seedYearForChecks: 2025)
                : PersistenceController.shared
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
