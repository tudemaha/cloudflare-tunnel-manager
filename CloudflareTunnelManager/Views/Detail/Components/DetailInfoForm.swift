//
//  DetailInfoForm.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailInfoForm: View {
    let tunnel: Tunnel
    @State private var copiedCommand = false

    var body: some View {
        Form {
            Section("Tunnel Details") {
                LabeledContent("Remote Hostname", value: tunnel.remoteHostname.absoluteString)
                LabeledContent("Connection Type", value: tunnel.connectionType.displayName)
                LabeledContent("Local Hostname", value: tunnel.localHostname)
                LabeledContent("Local Port", value: String(tunnel.localPort))
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
        "cloudflared access \(tunnel.connectionType.rawValue) --hostname \(tunnel.remoteHostname.absoluteString) --url \(tunnel.localHostname):\(tunnel.localPort)"
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tunnel.self, configurations: config)
    for sample in Tunnel.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailInfoForm(tunnel: Tunnel.sampleData.first!)
        .modelContainer(container)
}
