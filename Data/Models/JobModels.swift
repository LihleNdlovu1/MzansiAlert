//
//  JobModels.swift
//  MzansiAlert
//
//  Created by Assistant on 2025/10/07.
//

import Foundation
import SwiftUI

struct Job: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var company: String
    var location: String
    var description: String
    var postedAt: Date
    var contactEmail: String
    var employmentType: EmploymentType
}

enum EmploymentType: String, CaseIterable, Identifiable, Codable {
    case fullTime = "Full-time"
    case partTime = "Part-time"
    case contract = "Contract"
    case internship = "Internship"
    case temporary = "Temporary"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .fullTime: return .green
        case .partTime: return .blue
        case .contract: return .orange
        case .internship: return .purple
        case .temporary: return .pink
        }
    }
}


