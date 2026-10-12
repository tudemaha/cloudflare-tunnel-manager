//
//  TunnelFormView.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct TunnelFormView: View {
    var tunnel: Tunnel? = nil
    
    @Environment(\.dismiss) private var dismiss

    @State private var remoteHostname: String
    @State private var localHostname: String
    @State private var localPort: String
    @State private var connectionType: ConnectionType
    
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    init(tunnel: Tunnel? = nil) {
        self.tunnel = tunnel
        _remoteHostname = State(initialValue: tunnel?.remoteHostname.absoluteString ?? "")
        _localHostname = State(initialValue: tunnel?.localHostname ?? "localhost")
        _localPort = State(initialValue: tunnel != nil ? String(tunnel!.localPort) : "")
        _connectionType = State(initialValue: tunnel?.connectionType ?? .tcp)
    }

    private var isEditing: Bool {
        tunnel != nil
    }

    private var isValid: Bool {
        !remoteHostname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !localHostname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Int(localPort) != nil &&
        (1...65535).contains(Int(localPort)!)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Tunnel" : "Add Tunnel")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // Form Content
            Form {
                Section("Remote") {
                    TextField("Remote Hostname", text: $remoteHostname, prompt: Text("e.g. tcp.example.com"))
                    
                    Picker("Connection Type", selection: $connectionType) {
                        ForEach(ConnectionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Local") {
                    TextField("Local Hostname", text: $localHostname, prompt: Text("localhost"))
                    
                    TextField("Local Port", text: $localPort, prompt: Text("e.g. 2222"))
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal)

            Divider()

            // Actions
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(isEditing ? "Update" : "Save") {
                    saveTunnel()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 440, height: 380)
        .alert("Error Saving Tunnel", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveTunnel() {
        let trimmedRemote = remoteHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocal = localHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let port = Int(localPort), (1...65535).contains(port) else {
            errorMessage = "Port must be a valid number between 1 and 65535."
            showErrorAlert = true
            return
        }

        var cleanHostname = trimmedRemote
        if let range = cleanHostname.range(of: "://") {
            cleanHostname = String(cleanHostname[range.upperBound...])
        }
        cleanHostname = cleanHostname.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !cleanHostname.isEmpty, let url = URL(string: cleanHostname) else {
            errorMessage = "Please enter a valid remote hostname."
            showErrorAlert = true
            return
        }

        do {
            if let tunnel {
                tunnel.connectionType = connectionType
                tunnel.remoteHostname = url
                tunnel.localHostname = trimmedLocal
                tunnel.localPort = port
                try TunnelStorageManager.shared.save()
            } else {
                let newTunnel = Tunnel(
                    connectionType: connectionType,
                    remoteHostname: url,
                    localHostname: trimmedLocal,
                    localPort: port
                )
                try TunnelStorageManager.shared.add(tunnel: newTunnel)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview("Add Mode") {
    TunnelFormView()
        .modelContainer(for: Tunnel.self, inMemory: true)
}

#Preview("Edit Mode") {
    TunnelFormView(tunnel: Tunnel.sampleData.first!)
        .modelContainer(for: Tunnel.self, inMemory: true)
}
