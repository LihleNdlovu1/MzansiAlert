//
//  IncidentStore.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import SwiftUI

@MainActor
class IncidentStore: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService? = nil) {
        self.databaseService = databaseService ?? DatabaseService()
        
        // Bind to database service
        Task {
            await loadIncidents()
        }
    }
    
    // MARK: - Public Methods
    
    func loadIncidents() async {
        await databaseService.loadIncidents()
        incidents = databaseService.incidents
        isLoading = databaseService.isLoading
        errorMessage = databaseService.errorMessage
    }
    
    func addIncident(_ incident: Incident) {
        Task {
            await databaseService.addIncident(incident)
            await loadIncidents()
        }
    }
    
    func updateIncident(_ incident: Incident) {
        Task {
            await databaseService.updateIncident(incident)
            await loadIncidents()
        }
    }
    
    func deleteIncident(id: UUID) {
        Task {
            await databaseService.deleteIncident(id: id)
            await loadIncidents()
        }
    }
    
    func searchIncidents(query: String) async -> [Incident] {
        return incidents.filter { 
            $0.title.localizedCaseInsensitiveContains(query) || 
            $0.description.localizedCaseInsensitiveContains(query) 
        }
    }
    
    func fetchIncidents(by category: IncidentCategory) async -> [Incident] {
        return incidents.filter { $0.category == category }
    }
    
    func fetchIncidents(by status: IncidentStatus) async -> [Incident] {
        return incidents.filter { $0.status == status }
    }
    
    func fetchIncidents(by priority: Priority) async -> [Incident] {
        return incidents.filter { $0.priority == priority }
    }
    
    // MARK: - Statistics (Computed Properties)
    
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
}
