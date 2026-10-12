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

            if showTerminal || isRunning {
                Divider()

                TerminalView(access: access)
                    .padding(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showTerminal || isRunning)
        .onAppear {
            if access.state == .started {
                showTerminal = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
        
        withAnimation {
            if access.state == .started {
                access.state = .stopped
            } else {
                access.state = .started
                showTerminal = true
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
