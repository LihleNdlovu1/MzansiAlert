//
//  MapView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//
import SwiftUI
import MapKit
import PhotosUI
import CoreLocation

struct IncidentMapView: View {
    let incidents: [Incident]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -26.2041, longitude: 28.0473), // Johannesburg
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: incidents) { incident in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: incident.location.latitude,
                    longitude: incident.location.longitude
                )) {
                    VStack {
                        Image(systemName: incident.category.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(incident.category.color)
                            .clipShape(Circle())
                        
                        Text(incident.title)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
            .navigationTitle("Spot Incidents")
        }
    }
}

