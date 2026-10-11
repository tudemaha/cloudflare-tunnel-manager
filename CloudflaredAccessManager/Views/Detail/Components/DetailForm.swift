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

    @State private var remoteHostname: String
    @State private var localHostname: String
    @State private var localPort: String
    @State private var connectionType: ConnectionType

    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showSaveSuccess = false

    init(access: Access, onDelete: @escaping () -> Void) {
        self.access = access
        self.onDelete = onDelete
        _remoteHostname = State(initialValue: access.remoteHostname.absoluteString)
        _localHostname = State(initialValue: access.localHostname)
        _localPort = State(initialValue: String(access.localPort))
        _connectionType = State(initialValue: access.connectionType)
    }

    private var hasChanges: Bool {
        remoteHostname != access.remoteHostname.absoluteString ||
        localHostname != access.localHostname ||
        localPort != String(access.localPort) ||
        connectionType != access.connectionType
    }

    private var isValid: Bool {
        !remoteHostname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !localHostname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Int(localPort) != nil &&
        (1...65535).contains(Int(localPort)!)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: access.state.icon)
                    .font(.title2)
                    .foregroundStyle(access.state.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(access.remoteHostname.absoluteString)
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(access.connectionType.displayName)
                            .font(.caption.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .cornerRadius(4)

                        Text("Status: \(access.state.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
            .padding()

            Divider()

            // Form Content
            Form {
                Section("Remote Configuration") {
                    TextField("Remote Hostname", text: $remoteHostname, prompt: Text("e.g. ssh.example.com"))

                    Picker("Connection Type", selection: $connectionType) {
                        ForEach(ConnectionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Local Configuration") {
                    TextField("Local Hostname", text: $localHostname, prompt: Text("localhost"))

                    TextField("Local Port", text: $localPort, prompt: Text("e.g. 2222"))
                }

                Section("Command Preview") {
                    let cmd = "cloudflared access \(connectionType.rawValue) --hostname \(cleanHostnamePreview) --url \(localHostname):\(localPort)"
                    Text(cmd)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal)

            Divider()

            // Footer Actions
            HStack {
                if showSaveSuccess {
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }

                Spacer()

                if hasChanges {
                    Button("Revert") {
                        revertChanges()
                    }
                }

                Button("Save Changes") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasChanges || !isValid)
            }
            .padding()
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
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var cleanHostnamePreview: String {
        var clean = remoteHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = clean.range(of: "://") {
            clean = String(clean[range.upperBound...])
        }
        return clean.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func revertChanges() {
        remoteHostname = access.remoteHostname.absoluteString
        localHostname = access.localHostname
        localPort = String(access.localPort)
        connectionType = access.connectionType
    }

    private func saveChanges() {
        let trimmedRemote = remoteHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocal = localHostname.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let port = Int(localPort), (1...65535).contains(port) else {
            errorMessage = "Port must be a valid number between 1 and 65535."
            showErrorAlert = true
            return
        }

        var clean = trimmedRemote
        if let range = clean.range(of: "://") {
            clean = String(clean[range.upperBound...])
        }
        clean = clean.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !clean.isEmpty, let url = URL(string: clean) else {
            errorMessage = "Please enter a valid remote hostname."
            showErrorAlert = true
            return
        }

        access.remoteHostname = url
        access.localHostname = trimmedLocal
        access.localPort = port
        access.connectionType = connectionType

        do {
            try AccessStorageManager.shared.save()
            remoteHostname = clean
            withAnimation {
                showSaveSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
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
