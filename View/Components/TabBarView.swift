//
//  TabBarView.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    let tabAnimation: Namespace.ID
    
    private let tabItems = [
        TabItem(icon: "house.fill", title: "Home", tag: 0),
        TabItem(icon: "map.fill", title: "Map", tag: 1),
        TabItem(icon: "list.bullet", title: "Reports", tag: 2),
        TabItem(icon: "person.fill", title: "Profile", tag: 3)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.tag) { item in
                TabBarButton(
                    item: item,
                    selectedTab: $selectedTab,
                    tabAnimation: tabAnimation
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 25)
        .background(
            // Glassmorphism effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .mask(
                    RoundedRectangle(cornerRadius: 25)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

struct TabBarButton: View {
    let item: TabItem
    @Binding var selectedTab: Int
    let tabAnimation: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == item.tag
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectedTab = item.tag
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Background circle for selected state
                    if isSelected {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 50, height: 50)
                            .matchedGeometryEffect(id: "selectedTab", in: tabAnimation)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(item.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .opacity(isSelected ? 1 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(TabButtonStyle())
    }
}

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TabItem {
    let icon: String
    let title: String
    let tag: Int
}


