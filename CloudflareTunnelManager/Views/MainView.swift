//
//  MainView.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 10/10/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query private var tunnels: [Tunnel]
    @State private var selectedTunnel: Tunnel?

    var body: some View {
        NavigationSplitView {
            ListView(selectedTunnel: $selectedTunnel)
        } detail: {
            DetailView(selectedTunnel: $selectedTunnel)
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Tunnel.self, inMemory: true)
}
