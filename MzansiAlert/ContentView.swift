//
//  ContentView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI
import MapKit
import PhotosUI
import CoreLocation

struct ContentView: View {
    @StateObject private var incidentStore = IncidentStore()
    @StateObject private var jobStore = JobStore()
    @State private var showingReportSheet = false
    @State private var selectedTab = 0
    @Namespace private var tabAnimation
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.09)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area
                ZStack {
                    Group {
                        if selectedTab == 0 {
                            HomeView(incidentStore: incidentStore, jobStore: jobStore, showingReportSheet: $showingReportSheet)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else if selectedTab == 1 {
                            IncidentMapView(incidents: incidentStore.incidents)
                                .transition(.asymmetric(
                                    insertion: .move(edge: selectedTab > 1 ? .leading : .trailing).combined(with: .opacity),
                                    removal: .move(edge: selectedTab > 1 ? .trailing : .leading).combined(with: .opacity)
                                ))
                        } else if selectedTab == 2 {
                            ReportsView(incidents: incidentStore.incidents)
                                .transition(.asymmetric(
                                    insertion: .move(edge: selectedTab > 2 ? .leading : .trailing).combined(with: .opacity),
                                    removal: .move(edge: selectedTab > 2 ? .trailing : .leading).combined(with: .opacity)
                                ))
                        } else if selectedTab == 3 {
                            ProfileView()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar
                TabBarView(selectedTab: $selectedTab, tabAnimation: tabAnimation)
            }
        }
        .sheet(isPresented: $showingReportSheet) {
            ReportIncidentView(incidentStore: incidentStore)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}


#Preview {
    ContentView()
}
