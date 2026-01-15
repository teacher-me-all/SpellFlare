//
//  WatchLevelCompleteView.swift
//  SpellFlare Watch App
//
//  Level completion celebration screen.
//

import SwiftUI
import WatchKit

struct WatchLevelCompleteView: View {
    @EnvironmentObject var appState: WatchAppState

    let level: Int
    let score: Int

    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 12) {
            // Celebration icon
            ZStack {
                // Stars animation
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .offset(
                            x: showConfetti ? CGFloat.random(in: -40...40) : 0,
                            y: showConfetti ? CGFloat.random(in: -30...30) : 0
                        )
                        .opacity(showConfetti ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.8).delay(Double(index) * 0.1),
                            value: showConfetti
                        )
                }

                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }

            // Title
            Text("Level \(level)")
                .font(.headline)
                .foregroundColor(.cyan)

            Text("Complete!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Score
            Text("\(score)/10 correct")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 8)

            // Action buttons
            VStack(spacing: 8) {
                // Next Level button
                Button {
                    appState.startNextLevel(after: level)
                } label: {
                    HStack {
                        Text("Next Level")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cyan)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Home button
                Button {
                    appState.navigateToHome()
                } label: {
                    Text("Home")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            // Play success haptic
            WKInterfaceDevice.current().play(.success)

            // Trigger confetti animation
            withAnimation {
                showConfetti = true
            }

            // Play celebration audio
            WatchAudioService.shared.playFeedback(.levelComplete)
        }
    }
}

#Preview {
    WatchLevelCompleteView(level: 5, score: 8)
        .environmentObject(WatchAppState())
}
