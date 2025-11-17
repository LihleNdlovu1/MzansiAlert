//
//  CoreDataStack.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import CoreData
import Foundation

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataConfiguration.modelName)
        
        // Configure store description
        if let storeURL = CoreDataConfiguration.storeURL {
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.type = CoreDataConfiguration.storeType
            storeDescription.options = CoreDataConfiguration.storeOptions
            storeDescription.shouldAddStoreAsynchronously = CoreDataConfiguration.shouldAddStoreAsynchronously
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                // Handle migration errors
                if CoreDataConfiguration.shouldDeleteIncompatibleStores {
                    self?.deleteIncompatibleStore(storeDescription: storeDescription)
                } else {
                    fatalError("Core Data error: \(error), \(error.userInfo)")
                }
            }
        }
        
        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil // Disable undo for better performance
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveContext() {
        save()
    }
    
    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Store Management
    
    private func deleteIncompatibleStore(storeDescription: NSPersistentStoreDescription?) {
        guard let storeURL = storeDescription?.url else { return }
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, type: CoreDataConfiguration.storeType)
            
            // Reload the store
            persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    print("Failed to reload store after deletion: \(error)")
                }
            }
        } catch {
            print("Failed to delete incompatible store: \(error)")
        }
    }
    
    // MARK: - Debugging
    
    func printStoreInfo() {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        for store in stores {
            print("Store: \(store), Type: \(store.type), URL: \(store.url?.absoluteString ?? "Unknown")")
        }
    }
}
