//
//  CloudflaredAccessManagerApp.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
//

import SwiftUI
import SwiftData

@main
struct CloudflaredAccessManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Access.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
