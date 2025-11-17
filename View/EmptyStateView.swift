//
//  EmptyStateView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .scaleEffect(animateIcon ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
            
            Text("No incidents reported yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Be the first to report an incident in your community")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .onAppear {
            animateIcon = true
        }
    }
}
