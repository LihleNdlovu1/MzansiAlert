//
//  HomeView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//
import SwiftUI
import MapKit
import PhotosUI
import CoreLocation

struct HomeView: View {
    @ObservedObject var incidentStore: IncidentStore
    @ObservedObject var jobStore: JobStore
    @Binding var showingReportSheet: Bool
    @StateObject private var animationService = AnimationService()
    @State private var currentSlide = 0
    
    private let slides: [SlideData] = {
        let slide1 = SlideData(
            title: "Save Water",
            subtitle: "Turn off shower after 5 minutes",
            imageName: "save_water",
            isAssetImage: true,
            backgroundColor: Color.blue.opacity(0.1),
            accentColor: Color.blue
        )
        
        let slide2 = SlideData(
            title: "Load Shedding Alert",
            subtitle: "Stage 2 from 6PM - 10PM",
            imageName: "loadshedding",
            isAssetImage: true,
            backgroundColor: Color.yellow.opacity(0.1),
            accentColor: Color.orange
        )
        
        let slide3 = SlideData(
            title: "Community Safety",
            subtitle: "Report suspicious activities",
            imageName: "community_safety",
            isAssetImage: true,
            backgroundColor: Color.green.opacity(0.1),
            accentColor: Color.green
        )
        
        let slide4 = SlideData(
            title: "Emergency Contacts",
            subtitle: "Keep important numbers handy",
            imageName: "phone.circle.fill",
            isAssetImage: false,
            backgroundColor: Color.red.opacity(0.1),
            accentColor: Color.red
        )
        
        let slide5 = SlideData(
            title: "Reuse Reduce Recycle",
            subtitle: "Protect our environment",
            imageName: "recycle",
            isAssetImage: true,
            backgroundColor: Color.orange.opacity(0.1),
            accentColor: Color.orange
        )
        
        return [slide1, slide2, slide3, slide4, slide5]
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Animated Header with Careers shortcut
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MzansiAlert")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            Text("Building safer communities together")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        NavigationLink(destination: CareersView(jobStore: jobStore)) {
                            HStack(spacing: 6) {
                                Image(systemName: "briefcase.fill")
                                    .font(.subheadline)
                                Text("Careers")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .opacity(animationService.animateStats ? 1 : 0)
                    .offset(y: animationService.animateStats ? 0 : -20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animationService.animateStats)
                    
                    // Sliding Banner
                    SlidingBannerView(slides: slides, currentSlide: $currentSlide)
                        .frame(height: 180)
                        .padding(.horizontal)
                        .opacity(animationService.animateStats ? 1 : 0)
                        .offset(y: animationService.animateStats ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animationService.animateStats)
                    
             
                    Button(action: {
                        showingReportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Report Incident")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .scaleEffect(animationService.animateButton ? 1 : 0.9)
                    .opacity(animationService.animateButton ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: animationService.animateButton)
                    
 //Recent Incidents
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Incidents")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        if incidentStore.incidents.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(incidentStore.incidents.prefix(5)) { incident in
                                    IncidentCard(incident: incident)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .opacity(animationService.animateStats ? 1 : 0)
                    .offset(y: animationService.animateStats ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: animationService.animateStats)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            animationService.startHomeAnimations()
        }
    }
}

// MARK: - Supporting Views
struct SlidingBannerView: View {
    let slides: [SlideData]
    @Binding var currentSlide: Int
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                HStack {
                    ZStack {
                        if slides[currentSlide].isAssetImage {
                            Image(slides[currentSlide].imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 76)
                                .clipped()
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        } else {
                            Image(systemName: slides[currentSlide].imageName)
                                .font(.system(size: 56))
                                .foregroundColor(slides[currentSlide].accentColor)
                                .frame(width: 76, height: 76)
                                .background(slides[currentSlide].backgroundColor)
                                .clipShape(Circle())
                                .shadow(color: slides[currentSlide].accentColor.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(slides[currentSlide].title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(slides[currentSlide].subtitle)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentSlide ? slides[currentSlide].accentColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentSlide ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentSlide)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onTapGesture {
            nextSlide()
        }
        .animation(.easeInOut(duration: 0.5), value: currentSlide)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            nextSlide()
        }
    }
    
    private func nextSlide() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentSlide = (currentSlide + 1) % slides.count
        }
    }
}

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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @State private var animateValue = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .scaleEffect(animateValue ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.6), value: animateValue)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateValue = true
            }
        }
    }
}

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


