//
//  ViewTransitions.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

// View Transitions
extension View {
    func fadeSlideTransition(from edge: Edge) -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge.opposite).combined(with: .opacity)
        ))
    }
}

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading 
        }
    }
}


