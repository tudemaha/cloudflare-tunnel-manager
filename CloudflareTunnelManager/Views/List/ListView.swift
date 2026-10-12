//
//  ListView.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Query private var tunnels: [Tunnel]
    @Binding var selectedTunnel: Tunnel?
    
    @State private var isShowAddSheet = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        List(selection: $selectedTunnel) {
            ForEach(tunnels) { tunnel in
                Item(tunnel: tunnel)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteTunnel(tunnel)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if tunnels.isEmpty {
                ContentUnavailableView {
                    Label("No Tunnels", systemImage: "network.slash")
                } description: {
                    Text("Add a tunnel to get started.")
                } actions: {
                    Button {
                        isShowAddSheet = true
                    } label: {
                        Label("Add Tunnel", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 400)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    isShowAddSheet = true
                } label: {
                    Label("Add Tunnel", systemImage: "plus")
                }
                .help("Add new Cloudflared tunnel")
            }
        }
        .sheet(isPresented: $isShowAddSheet) {
            TunnelFormView()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func deleteTunnel(_ tunnel: Tunnel) {
        if selectedTunnel == tunnel {
            selectedTunnel = nil
        }
        do {
            try TunnelStorageManager.shared.delete(tunnel: tunnel)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview("Populated") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tunnel.self, configurations: config)
    for sample in Tunnel.sampleData {
        container.mainContext.insert(sample)
    }
    
    return ListView(selectedTunnel: .constant(Tunnel.sampleData.first))
        .modelContainer(container)
}

#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tunnel.self, configurations: config)
    
    return ListView(selectedTunnel: .constant(nil))
        .modelContainer(container)
}
