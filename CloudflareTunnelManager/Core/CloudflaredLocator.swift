//
//  CloudflaredLocator.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 12/10/2026.
//

import Foundation

enum CloudflaredLocator {
    static let candidatePaths = [
        "/opt/homebrew/bin/cloudflared",
        "/usr/local/bin/cloudflared",
        "/usr/bin/cloudflared"
    ]
    
    static func findBinary() -> URL? {
        for path in candidatePaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                return URL(filePath: path)
            }
        }
        return nil
    }
}
