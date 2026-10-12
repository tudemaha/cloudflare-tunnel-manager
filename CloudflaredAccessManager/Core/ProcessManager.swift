//
//  ProcessManager.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 12/10/2026.
//

import Foundation
import SwiftData
import AppKit

@MainActor
@Observable
class ProcessManager {
    static let shared = ProcessManager()
    
    private var activeProcesses: [String: Process] = [:]
    private var activePipes: [String: Pipe] = [:]
    
    var logs: [String: [String]] = [:]
    
    private init() {
        NotificationCenter.default
            .addObserver(
                forName: NSApplication.willTerminateNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in MainActor.assumeIsolated {
                    self?.stopAll()
                }
            }
    }
    
    func isRunning(for host: String) -> Bool {
        activeProcesses[host]?.isRunning ?? false
    }
    
    func start(access: Access) throws {
        let host = access.remoteHostname.absoluteString
        
        stop(for: host)
        
        guard let binaryURL = CloudflaredLocator.findBinary() else {
            throw ProcessError.binaryNotFound
        }
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = binaryURL
        
        let localAddress = "\(access.localHostname):\(access.localPort)"
        process.arguments = [
            "access",
            access.connectionType.rawValue,
            "--hostname", host,
            "--url", localAddress
        ]
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            
            DispatchQueue.main.async {
                self?.appendLog(text, for: host)
            }
        }
        
        process.terminationHandler = { [weak self] proc in
            DispatchQueue.main.async {
                self?.appendLog(
                    "Process terminated with exit code \(proc.terminationStatus)",
                    for: host
                )
                self?.activeProcesses.removeValue(forKey: host)
                self?.activePipes.removeValue(forKey: host)
            }
        }
        
        try process.run()
        
        activeProcesses[host] = process
        activePipes[host] = pipe
        appendLog(
            "cloudflared started successfully (PID: \(process.processIdentifier)",
            for: host
        )
        
    }
    
    func stop(for host: String) {
        guard let process = activeProcesses[host] else { return }
        
        activePipes[host]?.fileHandleForReading.readabilityHandler = nil
        if process.isRunning {
            process.terminate()
        }
        
        activeProcesses.removeValue(forKey: host)
        activePipes.removeValue(forKey: host)
        appendLog("Process stopped by user", for: host)
    }
    
    func stopAll() {
        for (host, _) in activeProcesses {
            stop(for: host)
        }
        AccessStorageManager.shared.resetAllStatesToStopped()
    }
    
    private func appendLog(_ text: String, for host: String) {
        let lines = text.components(separatedBy: .newlines).filter {
            !$0.isEmpty
        }
        
        if logs[host] == nil {
            logs[host] = []
        }
        logs[host]?.append(contentsOf: lines)
    }
}

enum ProcessError: LocalizedError {
    case binaryNotFound
    
    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return "cloudflared is not found. Please install it using 'brew install cloudflared'."
        }
    }
}
