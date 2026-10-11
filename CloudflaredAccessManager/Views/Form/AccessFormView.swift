//
//  AccessFormView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct AccessFormView: View {
    var access: Access? = nil
    
    @Environment(\.dismiss) private var dismiss

    @State private var remoteHostname: String
    @State private var localHostname: String
    @State private var localPort: String
    @State private var connectionType: ConnectionType
    
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    init(access: Access? = nil) {
        self.access = access
        _remoteHostname = State(initialValue: access?.remoteHostname.absoluteString ?? "")
        _localHostname = State(initialValue: access?.localHostname ?? "localhost")
        _localPort = State(initialValue: access != nil ? String(access!.localPort) : "")
        _connectionType = State(initialValue: access?.connectionType ?? .tcp)
    }

    private var isEditing: Bool {
        access != nil
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
                Text(isEditing ? "Edit Connection" : "Add Connection")
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
                    saveAccess()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 440, height: 380)
        .alert("Error Saving Connection", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveAccess() {
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
            if let access {
                access.connectionType = connectionType
                access.remoteHostname = url
                access.localHostname = trimmedLocal
                access.localPort = port
                try AccessStorageManager.shared.save()
            } else {
                let newAccess = Access(
                    connectionType: connectionType,
                    remoteHostname: url,
                    localHostname: trimmedLocal,
                    localPort: port
                )
                try AccessStorageManager.shared.add(access: newAccess)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview("Add Mode") {
    AccessFormView()
        .modelContainer(for: Access.self, inMemory: true)
}

#Preview("Edit Mode") {
    AccessFormView(access: Access.sampleData.first!)
        .modelContainer(for: Access.self, inMemory: true)
}
