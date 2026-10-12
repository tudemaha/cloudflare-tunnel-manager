//
//  CloudflareTunnelManagerApp.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 10/10/2026.
//

import SwiftUI
import SwiftData

@main
struct CloudflareTunnelManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Tunnel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        TunnelStorageManager.shared.context = sharedModelContainer.mainContext
        TunnelStorageManager.shared.resetAllStatesToStopped()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
