//
//  TunnelStorageManager.swift
//  CloudflareTunnelManager
//
//  Created by Tude Maha on 10/10/2026.
//

import Foundation
import SwiftData

@MainActor
class TunnelStorageManager {
    static let shared = TunnelStorageManager()
    
    var context: ModelContext?
    
    private init() {}
    
    enum StorageError: LocalizedError {
        case contextMissing
        case saveFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .contextMissing: return "Database context is not initialized."
            case .saveFailed(
                let error
            ): return "Failed to save changes: \(error.localizedDescription)"
            }
        }
    }
    
    func add(tunnel: Tunnel) throws {
        guard let context = context else { throw StorageError.contextMissing }
        context.insert(tunnel)
        try save()
    }
    
    func delete(tunnel: Tunnel) throws {
        guard let context = context else { throw StorageError.contextMissing }
        context.delete(tunnel)
        try save()
    }
    
    func fetchAll() throws -> [Tunnel] {
        guard let context = context else { throw StorageError.contextMissing }
        let descriptor = FetchDescriptor<Tunnel>()
        return try context.fetch(descriptor)
    }
    
    func resetAllStatesToStopped() {
        guard let context = context else { return }
        do {
            let descriptor = FetchDescriptor<Tunnel>()
            let tunnels = try context.fetch(descriptor)
            var hasChanges = false
            for tunnel in tunnels where tunnel.state == .started {
                tunnel.state = .stopped
                hasChanges = true
            }
            if hasChanges {
                try save()
            }
        } catch {
            print("Failed to reset running tunnel states: \(error.localizedDescription)")
        }
    }
    
    func save() throws {
        guard let context = context else { throw StorageError.contextMissing }
        do {
            try context.save()
        } catch {
            throw StorageError.saveFailed(error)
        }
    }
}
