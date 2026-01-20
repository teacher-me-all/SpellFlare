//
//  WatchCoinsDisplayView.swift
//  SpellFlare Watch App
//
//  Compact coins display for Watch.
//

import SwiftUI

struct WatchCoinsDisplayView: View {
    let coins: Int
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: compact ? 11 : 14))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("\(coins)")
                .font(.system(size: compact ? 10 : 12, weight: .bold))
                .foregroundColor(.yellow)
                .monospacedDigit()
        }
        .padding(.horizontal, compact ? 5 : 8)
        .padding(.vertical, compact ? 2 : 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
    }
}

/// Coins earned animation for Watch
struct WatchCoinsEarnedView: View {
    let amount: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("+\(amount)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WatchCoinsDisplayView(coins: 450)
        WatchCoinsEarnedView(amount: 100)
    }
}
