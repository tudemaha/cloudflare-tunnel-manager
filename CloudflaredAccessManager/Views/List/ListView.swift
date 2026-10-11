//
//  AccessListView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Query private var accesses: [Access]
    @Binding var selectedAccess: Access?
    
    @State private var isShowAddSheet = false
    
    var body: some View {
        List(selection: $selectedAccess) {
            ForEach(accesses) { access in
                Item(access: access)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 400)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    isShowAddSheet = true
                } label: {
                    Label("Add Connection", systemImage: "plus")
                }
                .help("Add new Cloudflared access connection")
            }
        }
        .sheet(isPresented: $isShowAddSheet) {
            AddAccessSheet()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Access.self, configurations: config)
    for sample in Access.sampleData {
        container.mainContext.insert(sample)
    }
    
    return ListView(selectedAccess: .constant(Access.sampleData.first))
        .modelContainer(container)
}
