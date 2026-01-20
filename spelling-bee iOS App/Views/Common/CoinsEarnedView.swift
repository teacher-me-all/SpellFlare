//
//  CoinsEarnedView.swift
//  spelling-bee iOS App
//
//  Animated view showing coins earned after completing a level.
//

import SwiftUI

struct CoinsEarnedView: View {
    let amount: Int
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("+\(amount)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.3),
                            Color.orange.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offsetY)
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        // Spring scale animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }

        // Float up slightly
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            offsetY = -10
        }
    }
}

/// Full floating animation version for celebration
struct FloatingCoinsEarnedView: View {
    let amount: Int
    let onComplete: (() -> Void)?

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 20
    @State private var shimmer = false

    init(amount: Int, onComplete: (() -> Void)? = nil) {
        self.amount = amount
        self.onComplete = onComplete
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .yellow.opacity(0.5), radius: shimmer ? 10 : 5)

            Text("+\(amount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: shimmer ? 8 : 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
                .overlay(
                    Capsule()
                        .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offsetY)
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {
        // Spring in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
            offsetY = 0
        }

        // Shimmer effect
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.5)) {
            shimmer = true
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.2, blue: 0.9),
                Color(red: 0.5, green: 0.3, blue: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 30) {
            CoinsEarnedView(amount: 100)
            FloatingCoinsEarnedView(amount: 70)
        }
    }
}
