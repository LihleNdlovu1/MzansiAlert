//
//  IncidentModels.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import SwiftUI
import CoreLocation

struct Incident: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let category: IncidentCategory
    let location: LocationData
    let timestamp: Date
    let photos: [String]
    var status: IncidentStatus
    let priority: Priority
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
}

enum IncidentCategory: String, CaseIterable, Codable {
    case safety = "Safety"
    case infrastructure = "Infrastructure"
    case environmental = "Environmental"
    case traffic = "Traffic"
    case crime = "Crime"
    case utilities = "Utilities"
    case incident = "incident"
    
    var icon: String {
        switch self {
        case .safety:
            return "shield.fill"
        case .infrastructure:
            return "hammer.fill"
        case .environmental:
            return "leaf.fill"
        case .traffic:
            return "car.fill"
        case .crime:
            return "exclamationmark.triangle.fill"
        case .utilities:
            return "bolt.fill"
        case .incident:
            return "car.side.rear.and.collision.and.car.side.front"
        }
    }
    
    var color: Color {
        switch self {
        case .safety:
            return .blue
        case .infrastructure:
            return .orange
        case .environmental:
            return .green
        case .traffic:
            return .purple
        case .crime:
            return .red
        case .utilities:
            return .yellow
        case .incident:
            return .cyan
        }
    }
}

enum IncidentStatus: String, CaseIterable, Codable {
    case reported = "Reported"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case dismissed = "Dismissed"
    
    var color: Color {
        switch self {
        case .reported:
            return .blue
        case .inProgress:
            return .orange
        case .resolved:
            return .green
        case .dismissed:
            return .gray
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }
}



