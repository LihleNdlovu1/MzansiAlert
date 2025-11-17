//
//  ReportsView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI
import Foundation

struct ReportsView: View {
    let incidents: [Incident]
    @State private var selectedFilter: IncidentStatus? = nil
    
    var filteredIncidents: [Incident] {
        if let filter = selectedFilter {
            return incidents.filter { $0.status == filter }
        }
        return incidents
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(title: "Total Reports", value: "\(incidents.count)", icon: "doc.text.fill", color: .blue)
                    StatCard(title: "In Progress", value: "\(incidents.filter { $0.status == .inProgress }.count)", icon: "clock.fill", color: .orange)
                    StatCard(title: "Resolved", value: "\(incidents.filter { $0.status == .resolved }.count)", icon: "checkmark.circle.fill", color: .green)
                    StatCard(title: "High Priority", value: "\(incidents.filter { $0.priority == .high || $0.priority == .critical }.count)", icon: "exclamationmark.triangle.fill", color: .red)
                }
                .padding(.horizontal)
                .padding(.top)

                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        ForEach(IncidentStatus.allCases, id: \.self) { status in
                            FilterButton(title: status.rawValue, isSelected: selectedFilter == status) {
                                selectedFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Incidents list
                List(filteredIncidents) { incident in
                    IncidentCard(incident: incident)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("All Reports")
        }
    }
}
