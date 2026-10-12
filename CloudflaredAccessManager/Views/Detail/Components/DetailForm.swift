//
//  DetailForm.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailForm: View {
    let access: Access
    let onDelete: () -> Void

    @State private var isShowingEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showTerminal = true

    private var isRunning: Bool {
        access.state == .started
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(
                access: access,
                onEdit: {
                    isShowingEditSheet = true
                },
                onDelete: {
                    showDeleteConfirmation = true
                }
            )

            Divider()

            DetailInfoForm(access: access)
                .padding(.horizontal)

            if showTerminal {
                Divider()

                TerminalView(access: access)
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
                .help(isRunning ? "Stop connection" : "Start connection")
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            AccessFormView(access: access)
        }
        .confirmationDialog(
            "Delete Connection?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(access.remoteHostname.absoluteString)? This action cannot be undone.")
        }
    }

    private func togglePlay() {
        let host = access.remoteHostname.absoluteString
        
        withAnimation {
            if ProcessManager.shared.isRunning(for: host) {
                ProcessManager.shared.stop(for: host)
                access.state = .stopped
            } else {
                do {
                    try ProcessManager.shared.start(access: access)
                    access.state = .started
                } catch {
                    access.state = .failed
                    print("Failed to start process: \(error.localizedDescription)")
                }
            }
            try? AccessStorageManager.shared.save()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Access.self, configurations: config)
    for sample in Access.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailForm(
        access: Access.sampleData.first!,
        onDelete: { }
    )
    .modelContainer(container)
}
