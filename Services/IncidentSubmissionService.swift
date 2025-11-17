//
//  IncidentSubmissionService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import CoreLocation

class IncidentSubmissionService: ObservableObject {
    @Published var isSubmitting = false
    @Published var submissionError: String?
    
    func submitIncident(
        title: String,
        description: String,
        category: IncidentCategory,
        priority: Priority,
        location: CLLocation?,
        photos: [String],
        incidentStore: IncidentStore
    ) async {
        guard let location = location else {
            submissionError = "Location is required"
            return
        }
        
        isSubmitting = true
        submissionError = nil
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        let incident = Incident(
            title: title,
            description: description,
            category: category,
            location: LocationData(
                latitude: location.latitude,
                longitude: location.longitude,
                address: "Current Location"
            ),
            timestamp: Date(),
            photos: photos,
            status: .reported,
            priority: priority
        )
        
        // Simulate async submission
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            incidentStore.addIncident(incident)
            
            // Success haptic
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            isSubmitting = false
        }
    }
}



