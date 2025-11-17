//
//  DataMigrationService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreData

class DataMigrationService {
    private let databaseService: DatabaseService
    private let userDefaults = UserDefaults.standard
    private let migrationKey = "hasMigratedSampleData"
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }
    
    func migrateSampleDataIfNeeded() async {
        guard !hasMigratedSampleData() else { return }
        
        let sampleIncidents = createSampleIncidents()
        
        for incident in sampleIncidents {
            await databaseService.addIncident(incident)
        }
        
        markMigrationComplete()
        print("Sample data migration completed successfully")
    }
    
    private func hasMigratedSampleData() -> Bool {
        return userDefaults.bool(forKey: migrationKey)
    }
    
    private func markMigrationComplete() {
        userDefaults.set(true, forKey: migrationKey)
    }
    
    private func createSampleIncidents() -> [Incident] {
        return [
            Incident(
                title: "Pothole on Main Street",
                description: "Large pothole causing damage to vehicles near the intersection",
                category: .infrastructure,
                location: LocationData(latitude: -26.2041, longitude: 28.0473, address: "Main Street, Johannesburg"),
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                photos: [],
                status: .reported,
                priority: .medium
            ),
            Incident(
                title: "Street Light Out",
                description: "Street light has been out for 3 days, creating safety concerns",
                category: .utilities,
                location: LocationData(latitude: -26.2051, longitude: 28.0483, address: "Oak Avenue, Johannesburg"),
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                photos: [],
                status: .inProgress,
                priority: .high
            ),
            Incident(
                title: "Suspicious Activity",
                description: "Unusual activity reported in the area, multiple residents concerned",
                category: .crime,
                location: LocationData(latitude: -26.2031, longitude: 28.0463, address: "Park Street, Johannesburg"),
                timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
                photos: [],
                status: .reported,
                priority: .critical
            ),
            Incident(
                title: "Water Leak on Sidewalk",
                description: "Water is leaking from a broken pipe, creating a hazard for pedestrians",
                category: .utilities,
                location: LocationData(latitude: -26.2061, longitude: 28.0493, address: "Water Street, Johannesburg"),
                timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                photos: [],
                status: .inProgress,
                priority: .high
            ),
            Incident(
                title: "Graffiti on Building",
                description: "Vandalism reported on the side of the community center",
                category: .crime,
                location: LocationData(latitude: -26.2021, longitude: 28.0453, address: "Community Center, Johannesburg"),
                timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
                photos: [],
                status: .reported,
                priority: .low
            ),
            Incident(
                title: "Broken Traffic Light",
                description: "Traffic light at the intersection is not working properly",
                category: .traffic,
                location: LocationData(latitude: -26.2071, longitude: 28.0503, address: "Traffic Circle, Johannesburg"),
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                photos: [],
                status: .inProgress,
                priority: .high
            ),
            Incident(
                title: "Litter in Park",
                description: "Excessive litter accumulation in the local park",
                category: .environmental,
                location: LocationData(latitude: -26.2011, longitude: 28.0443, address: "Central Park, Johannesburg"),
                timestamp: Date().addingTimeInterval(-21600), // 6 hours ago
                photos: [],
                status: .reported,
                priority: .low
            ),
            Incident(
                title: "Noise Complaint",
                description: "Excessive noise from construction work during night hours",
                category: .safety,
                location: LocationData(latitude: -26.2081, longitude: 28.0513, address: "Construction Site, Johannesburg"),
                timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
                photos: [],
                status: .reported,
                priority: .medium
            )
        ]
    }
}



