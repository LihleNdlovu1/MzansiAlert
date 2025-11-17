//
//  AnimationService.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

class AnimationService: ObservableObject {
    @Published var animateStats = false
    @Published var animateButton = false
    @Published var cardOpacity = 0.0
    @Published var cardOffset = 50.0
    @Published var showFloatingButton = true
    
    func startHomeAnimations() {
        animateStats = true
        animateButton = true
    }
    
    func startFormAnimations() {
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            cardOpacity = 1.0
            cardOffset = 0
        }
    }
    
    func startFloatingButtonAnimation() {
        withAnimation(.easeInOut(duration: 1)) {
            showFloatingButton.toggle()
        }
    }
}



