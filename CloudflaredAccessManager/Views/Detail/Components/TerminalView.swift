//
//  TerminalView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct TerminalView: View {
    let access: Access
    private var processManager = ProcessManager.shared
    
    init(access: Access) {
        self.access = access
    }
    
    private var currentLogs: [String] {
        processManager.logs[access.remoteHostname.absoluteString] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(currentLogs.enumerated()), id: \.offset) { _, log in
                            Text(log)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.9))
                        }

                        // Invisible anchor view for bottom auto-scrolling
                        Color.clear
                            .frame(height: 1)
                            .id("bottomID")
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                }
                .defaultScrollAnchor(.bottom)
                .background(Color(red: 0.08, green: 0.09, blue: 0.11))
                .onChange(of: currentLogs.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("bottomID", anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo("bottomID", anchor: .bottom)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .frame(minHeight: 180, maxHeight: 260)
    }
}

#Preview {
    TerminalView(access: Access.sampleData.first!)
        .padding()
        .frame(width: 550, height: 300)
        .modelContainer(for: Access.self, inMemory: true)
}
