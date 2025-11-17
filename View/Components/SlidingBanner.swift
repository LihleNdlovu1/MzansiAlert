//
//  SlidingBanner.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/01.
//

import SwiftUI

struct SlidingBanner: View {
    let slides: [SlideData]
    @Binding var currentSlide: Int
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                
                HStack {
                    
                    Image(systemName: slides[currentSlide].imageName)
                        .font(.system(size: 40))
                        .foregroundColor(slides[currentSlide].accentColor)
                        .frame(width: 60, height: 60)
                        .background(slides[currentSlide].backgroundColor)
                        .clipShape(Circle())
                        .shadow(color: slides[currentSlide].accentColor.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(slides[currentSlide].title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(slides[currentSlide].subtitle)
                            .font(.subheadline)
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
                .padding(.vertical, 16)
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




