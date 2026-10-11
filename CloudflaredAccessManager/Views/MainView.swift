//
//  ContentView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accesses: [Access]
    @State private var selectedAccess: Access?

    var body: some View {
        HSplitView {
            ListView(selectedAccess: $selectedAccess)
            
            DetailView(selectedAccess: selectedAccess)
        }
        .onAppear {
            seedSampleDataIfNeeded()
        }
    }
    
    private func seedSampleDataIfNeeded() {
        if accesses.isEmpty {
            for sample in Access.sampleData {
                modelContext.insert(sample)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Access.self, configurations: config)
    for sample in Access.sampleData {
        container.mainContext.insert(sample)
    }
    return MainView()
        .modelContainer(container)
}
