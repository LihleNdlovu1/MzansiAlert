//
//  FormValidationService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation

class FormValidationService: ObservableObject {
    @Published var validationErrors: [String] = []
    
    func validateIncidentForm(title: String, description: String) -> Bool {
        validationErrors.removeAll()
        
        if title.isEmpty {
            validationErrors.append("Title is required")
        }
        
        if description.isEmpty {
            validationErrors.append("Description is required")
        }
        
        if title.count < 5 {
            validationErrors.append("Title must be at least 5 characters")
        }
        
        if description.count < 10 {
            validationErrors.append("Description must be at least 10 characters")
        }
        
        return validationErrors.isEmpty
    }
    
    func clearErrors() {
        validationErrors.removeAll()
    }
}



