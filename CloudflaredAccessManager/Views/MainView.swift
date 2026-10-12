//
//  ContentView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query private var accesses: [Access]
    @State private var selectedAccess: Access?

    var body: some View {
        NavigationSplitView {
            ListView(selectedAccess: $selectedAccess)
        } detail: {
            DetailView(selectedAccess: $selectedAccess)
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Access.self, inMemory: true)
}
