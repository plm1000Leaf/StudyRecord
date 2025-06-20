//
//  StudyRecordApp.swift
//  StudyRecord
//
//  Created by 千葉陽乃 on 2025/02/18.
//

import SwiftUI

@main
struct StudyRecordApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var snapshotManager = SnapshotManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(snapshotManager)
        }
    }
}
