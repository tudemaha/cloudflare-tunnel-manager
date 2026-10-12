//
//  Item.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct Item: View {
    var tunnel: Tunnel
    
    var body: some View {
        HStack {
            Text(tunnel.remoteHostname.absoluteString)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: tunnel.state.icon)
                .foregroundStyle(tunnel.state.color)
        }
        .padding(6)
        .tag(tunnel)
    }
}

#Preview {
    Item(tunnel: Tunnel.sampleData[0])
        .modelContainer(for: Tunnel.self, inMemory: true)
}
