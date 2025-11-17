//
//  DatabaseService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreData

@MainActor
class DatabaseService: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: IncidentRepositoryProtocol
    private let coreDataStack: CoreDataStack
    
    init(repository: IncidentRepositoryProtocol? = nil) {
        self.coreDataStack = CoreDataStack.shared
        self.repository = repository ?? CoreDataIncidentRepository(coreDataStack: coreDataStack)
        
        // Set up Core Data notifications
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    func loadIncidents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedIncidents = try await repository.fetchAllIncidents()
            incidents = fetchedIncidents
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading incidents: \(error)")
        }
        
        isLoading = false
    }
    
    func addIncident(_ incident: Incident) async {
        do {
            try await repository.addIncident(incident)
            // The incidents array will be updated automatically via Core Data notifications
        } catch {
            errorMessage = error.localizedDescription
            print("Error adding incident: \(error)")
        }
    }
    
    func updateIncident(_ incident: Incident) async {
        do {
            try await repository.updateIncident(incident)
            // The incidents array will be updated automatically via Core Data notifications
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating incident: \(error)")
        }
    }
    
    func deleteIncident(id: UUID) async {
        do {
            try await repository.deleteIncident(id: id)
            // The incidents array will be updated automatically via Core Data notifications
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting incident: \(error)")
        }
    }
    
    func searchIncidents(query: String) async -> [Incident] {
        do {
            return try await repository.searchIncidents(query: query)
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching incidents: \(error)")
            return []
        }
    }
    
    func fetchIncidents(by category: IncidentCategory) async -> [Incident] {
        do {
            return try await repository.fetchIncidents(by: category)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching incidents by category: \(error)")
            return []
        }
    }
    
    func fetchIncidents(by status: IncidentStatus) async -> [Incident] {
        do {
            return try await repository.fetchIncidents(by: status)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching incidents by status: \(error)")
            return []
        }
    }
    
    func fetchIncidents(by priority: Priority) async -> [Incident] {
        do {
            return try await repository.fetchIncidents(by: priority)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching incidents by priority: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    
    var totalIncidents: Int {
        incidents.count
    }
    
    var inProgressIncidents: Int {
        incidents.filter { $0.status == .inProgress }.count
    }
    
    var resolvedIncidents: Int {
        incidents.filter { $0.status == .resolved }.count
    }
    
    var highPriorityIncidents: Int {
        incidents.filter { $0.priority == .high || $0.priority == .critical }.count
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: coreDataStack.viewContext,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.loadIncidents()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



