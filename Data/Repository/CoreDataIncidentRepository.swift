//
//  CoreDataIncidentRepository.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreData

class CoreDataIncidentRepository: IncidentRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Operations
    
    func fetchAllIncidents() async throws -> [Incident] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \IncidentEntity.timestamp, ascending: false)]
                
                do {
                    let entities = try context.fetch(request)
                    let incidents = entities.compactMap { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incidents)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    func fetchIncident(by id: UUID) async throws -> Incident? {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let entities = try context.fetch(request)
                    let incident = entities.first.map { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incident)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    func fetchIncidents(by category: IncidentCategory) async throws -> [Incident] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "category == %@", category.rawValue)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \IncidentEntity.timestamp, ascending: false)]
                
                do {
                    let entities = try context.fetch(request)
                    let incidents = entities.compactMap { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incidents)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    func fetchIncidents(by status: IncidentStatus) async throws -> [Incident] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "status == %@", status.rawValue)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \IncidentEntity.timestamp, ascending: false)]
                
                do {
                    let entities = try context.fetch(request)
                    let incidents = entities.compactMap { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incidents)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    func fetchIncidents(by priority: Priority) async throws -> [Incident] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "priority == %@", priority.rawValue)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \IncidentEntity.timestamp, ascending: false)]
                
                do {
                    let entities = try context.fetch(request)
                    let incidents = entities.compactMap { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incidents)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    func searchIncidents(query: String) async throws -> [Incident] {
        return try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR incidentDescription CONTAINS[cd] %@", query, query)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \IncidentEntity.timestamp, ascending: false)]
                
                do {
                    let entities = try context.fetch(request)
                    let incidents = entities.compactMap { self.mapEntityToIncident($0) }
                    continuation.resume(returning: incidents)
                } catch {
                    continuation.resume(throwing: DatabaseError.fetchFailed(error))
                }
            }
        }
    }
    
    // MARK: - Write Operations
    
    func addIncident(_ incident: Incident) async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                do {
                    let entity = self.mapIncidentToEntity(incident, context: context)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DatabaseError.saveFailed(error))
                }
            }
        }
    }
    
    func updateIncident(_ incident: Incident) async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", incident.id as CVarArg)
                    request.fetchLimit = 1
                    
                    let entities = try context.fetch(request)
                    guard let entity = entities.first else {
                        continuation.resume(throwing: DatabaseError.incidentNotFound)
                        return
                    }
                    
                    self.updateEntity(entity, with: incident)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DatabaseError.saveFailed(error))
                }
            }
        }
    }
    
    func deleteIncident(id: UUID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    request.fetchLimit = 1
                    
                    let entities = try context.fetch(request)
                    guard let entity = entities.first else {
                        continuation.resume(throwing: DatabaseError.incidentNotFound)
                        return
                    }
                    
                    context.delete(entity)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DatabaseError.deleteFailed(error))
                }
            }
        }
    }
    
    // MARK: - Mapping Methods
    
    private func mapEntityToIncident(_ entity: IncidentEntity) -> Incident? {
        guard let id = entity.id,
              let title = entity.title,
              let description = entity.incidentDescription,
              let categoryString = entity.category,
              let category = IncidentCategory(rawValue: categoryString),
              let statusString = entity.status,
              let status = IncidentStatus(rawValue: statusString),
              let priorityString = entity.priority,
              let priority = Priority(rawValue: priorityString),
              let timestamp = entity.timestamp,
              let location = entity.location else {
            return nil
        }
        
        let locationData = LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address ?? ""
        )
        
        return Incident(
            id: id,
            title: title,
            description: description,
            category: category,
            location: locationData,
            timestamp: timestamp,
            photos: entity.photos ?? [],
            status: status,
            priority: priority
        )
    }
    
    private func mapIncidentToEntity(_ incident: Incident, context: NSManagedObjectContext) -> IncidentEntity {
        let entity = IncidentEntity(context: context)
        entity.id = incident.id
        entity.title = incident.title
        entity.incidentDescription = incident.description
        entity.category = incident.category.rawValue
        entity.status = incident.status.rawValue
        entity.priority = incident.priority.rawValue
        entity.timestamp = incident.timestamp
        entity.photos = incident.photos
        
        // Create location entity
        let locationEntity = LocationEntity(context: context)
        locationEntity.latitude = incident.location.latitude
        locationEntity.longitude = incident.location.longitude
        locationEntity.address = incident.location.address
        locationEntity.incident = entity
        
        return entity
    }
    
    private func updateEntity(_ entity: IncidentEntity, with incident: Incident) {
        entity.title = incident.title
        entity.incidentDescription = incident.description
        entity.category = incident.category.rawValue
        entity.status = incident.status.rawValue
        entity.priority = incident.priority.rawValue
        entity.timestamp = incident.timestamp
        entity.photos = incident.photos
        
        // Update location
        if let location = entity.location {
            location.latitude = incident.location.latitude
            location.longitude = incident.location.longitude
            location.address = incident.location.address
        }
    }
}

// MARK: - Database Errors

enum DatabaseError: LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case incidentNotFound
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch incidents: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save incident: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete incident: \(error.localizedDescription)"
        case .incidentNotFound:
            return "Incident not found"
        }
    }
}



