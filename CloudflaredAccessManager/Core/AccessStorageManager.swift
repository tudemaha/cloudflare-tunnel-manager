//
//  AccessStorageManager.swift
//  CloudflaredAccessManager
//
//  Created by Tude Maha on 10/10/2026.
//

import Foundation
import SwiftData

@MainActor
class AccessStorageManager {
    static let shared = AccessStorageManager()
    
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
    
    func add(access: Access) throws {
        guard let context = context else { throw StorageError.contextMissing }
        context.insert(access)
        try save()
    }
    
    func delete(access: Access) throws {
        guard let context = context else { throw StorageError.contextMissing }
        context.delete(access)
        try save()
    }
    
    func fetchAll() throws -> [Access] {
        guard let context = context else { throw StorageError.contextMissing }
        let descriptor = FetchDescriptor<Access>()
        return try context.fetch(descriptor)
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
