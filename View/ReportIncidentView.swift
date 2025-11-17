//
//  ReportIncidentView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//
import SwiftUI
import MapKit
import PhotosUI
import CoreLocation

struct ReportIncidentView: View {
    @ObservedObject var incidentStore: IncidentStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var animationService = AnimationService()
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = IncidentCategory.safety
    @State private var selectedPriority = Priority.medium
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var isSubmitting = false
    @State private var manualAddress = ""
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.pink.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 100...200))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...600)
                    )
                    .animation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true), value: animationService.cardOpacity)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Report Incident")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Help keep your community safe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Main Content Cards
                    VStack(spacing: 20) {
                        // Incident Details Card
                        GlassCard {
                            IncidentDetailsSection(title: $title, description: $description)
                        }
                        
                        // Category & Priority Card
                        GlassCard {
                            CategoryPrioritySection(
                                selectedCategory: $selectedCategory,
                                selectedPriority: $selectedPriority
                            )
                        }
                        
                        // Location Card
                        GlassCard {
                            LocationSection(locationManager: locationManager, manualAddress: $manualAddress)
                        }
                        
                        // Photos Card
                        GlassCard {
                            PhotosSection(selectedPhotos: $selectedPhotos)
                        }
                        
                        // Submit Button
                        SubmitButton(
                            isSubmitting: $isSubmitting,
                            isDisabled: title.isEmpty || description.isEmpty
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                submitIncident()
                            }
                        }
                    }
                    .opacity(animationService.cardOpacity)
                    .offset(y: animationService.cardOffset)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topTrailing) {
            // Custom close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(.trailing, 20)
            .padding(.top, 50)
        }
        .onAppear {
            locationManager.requestLocation()
            animationService.startFormAnimations()
        }
    }

    private func submitIncident() {
        guard !title.isEmpty && !description.isEmpty else {
            return
        }
        
        isSubmitting = true
        
        func finish(with coordinate: CLLocationCoordinate2D, address: String) {
            let incident = Incident(
                title: title,
                description: description,
                category: selectedCategory,
                location: LocationData(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    address: address.isEmpty ? "Unknown Location" : address
                ),
                timestamp: Date(),
                photos: [],
                status: .reported,
                priority: selectedPriority
            )
            incidentStore.addIncident(incident)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isSubmitting = false
                dismiss()
            }
        }
        
        let trimmed = manualAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(trimmed) { placemarks, error in
                if let loc = placemarks?.first?.location?.coordinate {
                    finish(with: loc, address: trimmed)
                } else if let current = locationManager.currentLocation {
                    finish(with: current, address: "Current Location")
                } else {
                    finish(with: CLLocationCoordinate2D(latitude: 0, longitude: 0), address: "Unknown Location")
                }
            }
            return
        }
        
        if let current = locationManager.currentLocation {
            finish(with: current, address: "Current Location")
        } else {
            finish(with: CLLocationCoordinate2D(latitude: 0, longitude: 0), address: "Unknown Location")
        }
    }
}
