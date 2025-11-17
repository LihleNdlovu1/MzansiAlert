//
//  IncidentCard.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

struct IncidentCard: View {
    let incident: Incident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(incident.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(incident.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: incident.category.icon)
                            .foregroundColor(incident.category.color)
                        Text(incident.category.rawValue)
                            .font(.caption)
                            .foregroundColor(incident.category.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(incident.category.color.opacity(0.1), in: Capsule())
                    
                    Text(incident.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(incident.status.color)
                        .frame(width: 8, height: 8)
                    Text(incident.status.rawValue)
                        .font(.caption)
                        .foregroundColor(incident.status.color)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(incident.priority.color)
                        .font(.caption)
                    Text(incident.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(incident.priority.color)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
