//
//  FormSections.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI
import PhotosUI
import CoreLocation

// MARK: - Section Components
struct IncidentDetailsSection: View {
    @Binding var title: String
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                Text("Incident Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    placeholder: "What happened?",
                    text: $title,
                    icon: "pencil"
                )
                
                CustomTextEditor(
                    placeholder: "Provide detailed description...",
                    text: $description
                )
            }
        }
    }
}

struct CategoryPrioritySection: View {
    @Binding var selectedCategory: IncidentCategory
    @Binding var selectedPriority: Priority
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(.orange)
                    .frame(width: 24, height: 24)
                Text("Category & Priority")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(IncidentCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                }
                
                // Priority Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            PriorityButton(
                                priority: priority,
                                isSelected: selectedPriority == priority
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPriority = priority
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LocationSection: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                Text("Location")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if locationManager.currentLocation != nil {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let location = locationManager.currentLocation {
                        Text("Current Location")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontDesign(.monospaced)
                    } else {
                        Text("Getting location...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Please enable location services")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PhotosSection: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "camera")
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
                Text("Photos")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(selectedPhotos.count)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.1), in: Capsule())
            }
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 5,
                matching: .images
            ) {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.purple)
                    
                    Text("Add Photos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Up to 5 images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.purple.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            }
        }
    }
}



