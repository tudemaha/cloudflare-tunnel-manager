//
//  TerminalView.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 11/10/2026.
//

import SwiftUI
import SwiftData

struct LogLine: Identifiable {
    let id = UUID()
    let timestamp: String
    let level: LogLevel
    let message: String

    enum LogLevel {
        case info
        case success
        case warning
        case error

        var tag: String {
            switch self {
            case .info: return "INF"
            case .success: return "OK "
            case .warning: return "WRN"
            case .error: return "ERR"
            }
        }

        var color: Color {
            switch self {
            case .info: return .cyan
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            }
        }
    }
}

struct TerminalView: View {
    let access: Access
    @State private var logs: [LogLine] = []
    @State private var copied: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(logs) { log in
                            HStack(alignment: .top, spacing: 6) {
                                Text(log.timestamp)
                                    .foregroundStyle(.white.opacity(0.4))

                                Text(log.level.tag)
                                    .foregroundStyle(log.level.color)
                                    .fontWeight(.bold)

                                Text(log.message)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .font(.system(size: 11, design: .monospaced))
                            .textSelection(.enabled)
                            .id(log.id)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(red: 0.08, green: 0.09, blue: 0.11))
                .onChange(of: logs.count) { _, _ in
                    if let lastId = logs.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .frame(minHeight: 180, maxHeight: 260)
        .onAppear {
            generateDummyLogs()
        }
        .onChange(of: access.persistentModelID) { _, _ in
            generateDummyLogs()
        }
    }

    private func generateDummyLogs() {
        let host = access.remoteHostname.absoluteString
        let local = "\(access.localHostname):\(access.localPort)"
        let type = access.connectionType.displayName

        logs = [
            LogLine(timestamp: "18:15:00", level: .info, message: "cloudflared version 2026.10.0 (darwin/arm64)"),
            LogLine(timestamp: "18:15:00", level: .info, message: "Executing: cloudflared access \(access.connectionType.rawValue) --hostname \(host) --url \(local)"),
            LogLine(timestamp: "18:15:01", level: .info, message: "Resolving edge ingress endpoints..."),
            LogLine(timestamp: "18:15:01", level: .info, message: "Connecting to Cloudflare Edge [2606:4700::6810:85e5:443]..."),
            LogLine(timestamp: "18:15:02", level: .success, message: "QUIC connection established with Cloudflare Edge"),
            LogLine(timestamp: "18:15:02", level: .info, message: "Authenticating Access credentials for target \(host)..."),
            LogLine(timestamp: "18:15:03", level: .success, message: "Access verification successful. Session ID: 9e4f2b-81a"),
            LogLine(timestamp: "18:15:03", level: .info, message: "Binding local listener on \(local) (\(type))..."),
            LogLine(timestamp: "18:15:03", level: .success, message: "Ready! Tunnel active and forwarding traffic: \(local) <-> \(host)")
        ]
    }
}

#Preview {
    TerminalView(access: Access.sampleData.first!)
        .padding()
        .frame(width: 550, height: 300)
}
