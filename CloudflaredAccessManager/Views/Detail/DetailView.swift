//
//  DetailView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Query private var accesses: [Access]
    var selectedAccess: Access?
    
    var body: some View {
        VStack {
            if let selectedAccess {
                Text(selectedAccess.remoteHostname.absoluteString)
            } else {
                Text("Select an access")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DetailView()
}
