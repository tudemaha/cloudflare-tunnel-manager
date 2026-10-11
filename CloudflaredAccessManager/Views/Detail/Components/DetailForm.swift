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

    @State private var isShowingEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            DetailHeader(
                access: access,
                onEdit: {
                    isShowingEditSheet = true
                },
                onDelete: {
                    showDeleteConfirmation = true
                }
            )

            Divider()

            DetailInfoForm(access: access)
                .padding(.horizontal)
        }
        .sheet(isPresented: $isShowingEditSheet) {
            AccessFormView(access: access)
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
