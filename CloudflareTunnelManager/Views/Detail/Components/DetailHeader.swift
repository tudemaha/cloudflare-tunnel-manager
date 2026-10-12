//
//  DetailHeader.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI

struct DetailHeader: View {
    let tunnel: Tunnel
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tunnel.state.icon)
                .font(.title2)
                .foregroundStyle(tunnel.state.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(tunnel.remoteHostname.absoluteString)
                    .font(.title3.bold())
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(tunnel.connectionType.displayName)
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .cornerRadius(4)

                    Text("Status: \(tunnel.state.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    DetailHeader(
        tunnel: Tunnel.sampleData.first!,
        onEdit: { },
        onDelete: { }
    )
}
