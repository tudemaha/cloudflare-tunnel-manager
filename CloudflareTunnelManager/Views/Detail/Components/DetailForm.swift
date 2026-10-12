//
//  DetailForm.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailForm: View {
    let tunnel: Tunnel
    let onDelete: () -> Void

    @State private var isShowingEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showTerminal = true

    private var isRunning: Bool {
        tunnel.state == .started
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(
                tunnel: tunnel,
                onEdit: {
                    isShowingEditSheet = true
                },
                onDelete: {
                    showDeleteConfirmation = true
                }
            )

            Divider()

            DetailInfoForm(tunnel: tunnel)
                .padding(.horizontal)

            if showTerminal {
                Divider()

                TerminalView(tunnel: tunnel)
                    .padding(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showTerminal)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    withAnimation {
                        showTerminal.toggle()
                    }
                } label: {
                    Label(
                        showTerminal ? "Hide Terminal" : "Show Terminal",
                        systemImage: showTerminal ? "terminal.fill" : "terminal"
                    )
                }
                .help(showTerminal ? "Hide terminal output" : "Show terminal output")

                Button {
                    togglePlay()
                } label: {
                    if isRunning {
                        Label("Stop", systemImage: "stop.fill")
                            .foregroundStyle(.red)
                    } else {
                        Label("Start", systemImage: "play.fill")
                            .foregroundStyle(.green)
                    }
                }
                .help(isRunning ? "Stop tunnel" : "Start tunnel")
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            TunnelFormView(tunnel: tunnel)
        }
        .confirmationDialog(
            "Delete Tunnel?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(tunnel.remoteHostname.absoluteString)? This action cannot be undone.")
        }
    }

    private func togglePlay() {
        let host = tunnel.remoteHostname.absoluteString
        
        withAnimation {
            if ProcessManager.shared.isRunning(for: host) {
                ProcessManager.shared.stop(for: host)
                tunnel.state = .stopped
            } else {
                do {
                    try ProcessManager.shared.start(tunnel: tunnel)
                    tunnel.state = .started
                } catch {
                    tunnel.state = .failed
                    print("Failed to start process: \(error.localizedDescription)")
                }
            }
            try? TunnelStorageManager.shared.save()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tunnel.self, configurations: config)
    for sample in Tunnel.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailForm(
        tunnel: Tunnel.sampleData.first!,
        onDelete: { }
    )
    .modelContainer(container)
}
