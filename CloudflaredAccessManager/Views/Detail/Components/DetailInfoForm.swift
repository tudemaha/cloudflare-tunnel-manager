//
//  DetailInfoForm.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailInfoForm: View {
    let access: Access
    @State private var copiedCommand = false

    var body: some View {
        Form {
            Section("Connection Details") {
                LabeledContent("Remote Hostname", value: access.remoteHostname.absoluteString)
                LabeledContent("Connection Type", value: access.connectionType.displayName)
                LabeledContent("Local Hostname", value: access.localHostname)
                LabeledContent("Local Port", value: String(access.localPort))
            }

            Section("Command Preview") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(commandString)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)

                    HStack {
                        Spacer()
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(commandString, forType: .string)
                            withAnimation {
                                copiedCommand = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    copiedCommand = false
                                }
                            }
                        } label: {
                            Label(copiedCommand ? "Copied!" : "Copy Command", systemImage: copiedCommand ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var commandString: String {
        "cloudflared access \(access.connectionType.rawValue) --hostname \(access.remoteHostname.absoluteString) --url \(access.localHostname):\(access.localPort)"
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Access.self, configurations: config)
    for sample in Access.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailInfoForm(access: Access.sampleData.first!)
        .modelContainer(container)
}
