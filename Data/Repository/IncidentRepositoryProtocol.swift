//
//  IncidentRepositoryProtocol.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreData

protocol IncidentRepositoryProtocol {
    func fetchAllIncidents() async throws -> [Incident]
    func fetchIncident(by id: UUID) async throws -> Incident?
    func addIncident(_ incident: Incident) async throws
    func updateIncident(_ incident: Incident) async throws
    func deleteIncident(id: UUID) async throws
    func fetchIncidents(by category: IncidentCategory) async throws -> [Incident]
    func fetchIncidents(by status: IncidentStatus) async throws -> [Incident]
    func fetchIncidents(by priority: Priority) async throws -> [Incident]
    func searchIncidents(query: String) async throws -> [Incident]
}



