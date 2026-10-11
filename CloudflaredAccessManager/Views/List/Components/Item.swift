//
//  Item.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct Item: View {
    var access: Access
    var body: some View {
        HStack {
            Text(access.remoteHostname.absoluteString)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: access.state.icon)
                .foregroundStyle(access.state.color)
        }
        .padding(6)
        .tag(access)
    }
}

#Preview {
    Item(access: Access.sampleData[0])
        .modelContainer(for: Access.self, inMemory: true)
}
