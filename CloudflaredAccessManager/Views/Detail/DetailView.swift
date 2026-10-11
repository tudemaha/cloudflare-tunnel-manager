//
//  DetailView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Binding var selectedAccess: Access?

    var body: some View {
        Group {
            if let access = selectedAccess {
                DetailForm(
                    access: access,
                    onDelete: {
                        deleteAccess(access)
                    }
                )
                .id(access.persistentModelID)
            } else {
                ContentUnavailableView(
                    "No Connection Selected",
                    systemImage: "network",
                    description: Text("Select an access from the sidebar to view or edit its details.")
                )
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteAccess(_ access: Access) {
        selectedAccess = nil
        do {
            try AccessStorageManager.shared.delete(access: access)
        } catch {
            print("Failed to delete access: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Access.self, configurations: config)
    for sample in Access.sampleData {
        container.mainContext.insert(sample)
    }

    return DetailView(selectedAccess: .constant(Access.sampleData.first))
        .modelContainer(container)
}
