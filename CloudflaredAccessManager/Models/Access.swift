//
//  Item.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
//

import Foundation
import SwiftData
import SwiftUI

enum ConnectionType: String, Codable, CaseIterable, Identifiable {
    case tcp
    case rdp
    case ssh
    case smb
    
    var id: String { self.rawValue }
    
    var displayName: String {
        self.rawValue.uppercased()
    }
}

enum execState: String, Codable {
    case started = "Started"
    case stopped = "Stopped"
    case failed = "Failed"
    
    var icon: String {
        switch self {
        case .started: return "play.fill"
        case .stopped: return "stop.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .started: return .green
        case .stopped: return .gray
        case .failed: return .red
        }
    }
}

@Model
final class Access {
    var connectionType: ConnectionType
    @Attribute(.unique) var remoteHostname: URL
    var localHostname: String
    var localPort: Int
    var state: execState
    
    init(
        connectionType: ConnectionType,
        remoteHostname: URL,
        localHostname: String,
        localPort: Int
    ) {
        self.connectionType = connectionType
        self.remoteHostname = remoteHostname
        self.localHostname = localHostname
        self.localPort = localPort
        self.state = .stopped
    }
}

extension Access {
    @MainActor
    static var sampleData: [Access] {
        let sample1 = Access(
            connectionType: .ssh,
            remoteHostname: URL(string: "ssh.production.example.com")!,
            localHostname: "localhost",
            localPort: 2222
        )
        sample1.state = .started

        let sample2 = Access(
            connectionType: .rdp,
            remoteHostname: URL(string: "desktop.office.internal")!,
            localHostname: "localhost",
            localPort: 3389
        )
        sample2.state = .stopped

        let sample3 = Access(
            connectionType: .tcp,
            remoteHostname: URL(string: "db.internal.net")!,
            localHostname: "127.0.0.1",
            localPort: 5432
        )
        sample3.state = .failed

        let sample4 = Access(
            connectionType: .smb,
            remoteHostname: URL(string: "nas.storage.corp")!,
            localHostname: "localhost",
            localPort: 445
        )
        sample4.state = .stopped

        return [sample1, sample2, sample3, sample4]
    }
}
