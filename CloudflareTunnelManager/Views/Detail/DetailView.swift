//
//  DetailView.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Binding var selectedTunnel: Tunnel?

    var body: some View {
        Group {
            if let tunnel = selectedTunnel {
                DetailForm(
                    tunnel: tunnel,
                    onDelete: {
                        deleteTunnel(tunnel)
                    }
                )
                .id(tunnel.persistentModelID)
            } else {
                ContentUnavailableView(
                    "No Tunnel Selected",
                    systemImage: "network",
                    description: Text("Select a tunnel from the sidebar to view or edit its details.")
                )
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteTunnel(_ tunnel: Tunnel) {
        selectedTunnel = nil
        do {
            try TunnelStorageManager.shared.delete(tunnel: tunnel)
        } catch {
            print("Failed to delete tunnel: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tunnel.self, configurations: config)
    for sample in Tunnel.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailView(selectedTunnel: .constant(Tunnel.sampleData.first))
        .modelContainer(container)
}
