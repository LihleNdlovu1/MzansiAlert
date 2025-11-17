//
//  CoreDataConfiguration.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreData

struct CoreDataConfiguration {
    static let modelName = "MzansiAlert"
    static let storeType = NSSQLiteStoreType
    static let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("\(modelName).sqlite")
    
    // MARK: - Store Options
    static let storeOptions: [String: Any] = [
        NSPersistentStoreFileProtectionKey: FileProtectionType.completeUntilFirstUserAuthentication,
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    // MARK: - Batch Size Configuration
    static let defaultBatchSize = 20
    static let fetchBatchSize = 50
    
    // MARK: - Memory Management
    static let shouldDeleteIncompatibleStores = true
    static let shouldAddStoreAsynchronously = false
}



