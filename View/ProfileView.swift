//
//  ProfileView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

struct ProfileView: View {
    @State private var userName = "Lubelihle Ndlovu"
    @State private var userEmail = "lubelihlendlovu199@gmail.com"
    @State private var notificationsEnabled = true
    @State private var locationSharingEnabled = true
    @State private var darkMode = true
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Modern Profile Header with Gradient
                    VStack(spacing: 20) {
                        // Gradient Background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 16) {
                                //Profile Image with Glassmorphism Effect
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.white.opacity(0.8), .clear]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Text(String(userName.prefix(2)))
                                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(showEditProfile ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showEditProfile)
                                
                                VStack(spacing: 8) {
                                    Text(userName)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(userEmail)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.top, 40)
                        )
                        .clipped()
                        
                        // Edit Profile Button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showEditProfile.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil.circle.fill")
                                Text("Edit Profile")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, -30)
                        .scaleEffect(showEditProfile ? 1.05 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showEditProfile)
                    }
                    
                    // Modern Settings Cards
                    VStack(spacing: 24) {
                        // Preferences Card
                        ModernCard(title: "Preferences", icon: "gearshape.fill") {
                            VStack(spacing: 16) {
                                SettingsRow(
                                    icon: "bell.fill",
                                    title: "Push Notifications",
                                    iconColor: .blue,
                                    toggle: $notificationsEnabled
                                )
                                
                                Divider()
                                    .padding(.horizontal, -20)
                                
                                SettingsRow(
                                    icon: "location.fill",
                                    title: "Location Services",
                                    iconColor: .green,
                                    toggle: $locationSharingEnabled
                                )
                                
                                Divider()
                                    .padding(.horizontal, -20)
                                
                                SettingsRow(
                                    icon: "moon.fill",
                                    title: "Dark Appearance",
                                    iconColor: .purple,
                                    toggle: $darkMode
                                )
                            }
                        }
                        
                        // About Card
                        ModernCard(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 16) {
                                InfoRow(
                                    icon: "app.badge.fill",
                                    title: "App Version",
                                    value: "1.2.0",
                                    iconColor: .blue
                                )
                                
                                Divider()
                                    .padding(.horizontal, -20)
                                
                                NavigationRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    iconColor: .orange
                                )
                                
                                Divider()
                                    .padding(.horizontal, -20)
                                
                                NavigationRow(
                                    icon: "doc.text.fill",
                                    title: "Privacy Policy",
                                    iconColor: .gray
                                )
                            }
                        }
                        
                        // Sign Out Card
                        ModernCard(title: "", icon: "") {
                            Button(action: {
                                // Handle sign out with haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.red)
                                        .frame(width: 32, height: 32)
                                        .background(.red.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    Text("Sign Out")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct ModernCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !title.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            
            content
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    @Binding var toggle: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $toggle)
                .scaleEffect(0.9)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }
}

struct NavigationRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}
