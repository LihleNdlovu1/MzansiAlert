//
//  ErrorHandlingService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import Foundation
import SwiftUI

class ErrorHandlingService: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false
    
    func handleError(_ error: Error) {
        let appError = AppError.from(error)
        currentError = appError
        showError = true
        
        // Log error for debugging
        print("Error occurred: \(appError.localizedDescription)")
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
}

enum AppError: LocalizedError, Identifiable {
    case databaseError(DatabaseError)
    case networkError(String)
    case validationError(String)
    case unknownError(String)
    
    var id: String {
        switch self {
        case .databaseError(let error):
            return "database_\(error.localizedDescription)"
        case .networkError(let message):
            return "network_\(message)"
        case .validationError(let message):
            return "validation_\(message)"
        case .unknownError(let message):
            return "unknown_\(message)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let error):
            return "Database Error: \(error.localizedDescription)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknownError(let message):
            return "Error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .databaseError:
            return "Please try again. If the problem persists, restart the app."
        case .networkError:
            return "Please check your internet connection and try again."
        case .validationError:
            return "Please check your input and try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let databaseError = error as? DatabaseError {
            return .databaseError(databaseError)
        } else if let nsError = error as NSError? {
            if nsError.domain == NSURLErrorDomain {
                return .networkError(nsError.localizedDescription)
            }
        }
        return .unknownError(error.localizedDescription)
    }
}

// MARK: - Error Alert View

struct ErrorAlert: ViewModifier {
    @Binding var isPresented: Bool
    let error: AppError?
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $isPresented) {
                Button("OK") {
                    onDismiss?()
                }
            } message: {
                if let error = error {
                    VStack(alignment: .leading) {
                        Text(error.localizedDescription)
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
    }
}

extension View {
    func errorAlert(isPresented: Binding<Bool>, error: AppError?, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorAlert(isPresented: isPresented, error: error, onDismiss: onDismiss))
    }
}



