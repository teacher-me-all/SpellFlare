//
//  LevelCompleteView.swift
//  spelling-bee Watch App
//
//  Celebration screen shown when a level is completed.
//  Shows minimal static ad (brief delay) before navigation.
//

import SwiftUI

struct LevelCompleteView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var storeManager = StoreManager.shared

    let level: Int

    @State private var showConfetti = false
    @State private var starScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var showingAd = false
    @State private var pendingAction: (() -> Void)?
    @State private var adCountdown = 3

    private var shouldShowAd: Bool {
        !storeManager.isAdsRemoved
    }

    var body: some View {
        ZStack {
            if showingAd {
                // Simple static ad view
                WatchAdView(countdown: $adCountdown) {
                    showingAd = false
                    pendingAction?()
                    pendingAction = nil
                }
            } else {
                // Confetti background
                ConfettiView(isActive: $showConfetti)

                VStack(spacing: 8) {
                    // Trophy/Star
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.cyan, .white.opacity(0.3)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                            .scaleEffect(starScale)

                        Text("⭐")
                            .font(.system(size: 28))
                            .scaleEffect(starScale)
                    }

                    // Celebration text
                    VStack(spacing: 2) {
                        Text("Level \(level)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Complete!")
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                    }
                    .opacity(textOpacity)

                    Spacer()

                    // Two round buttons side by side
                    HStack(spacing: 16) {
                        // Home button
                        Button {
                            handleNavigation {
                                appState.completeLevel(level)
                                appState.navigateToHome()
                            }
                        } label: {
                            Image(systemName: "house.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .buttonStyle(.plain)

                        // Next level button (if not at max level)
                        if level < 50 {
                            Button {
                                handleNavigation {
                                    appState.completeLevel(level)
                                    appState.navigateToGame(level: level + 1)
                                }
                            } label: {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(Color.cyan))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .opacity(textOpacity)

                    // Minimal ad notice
                    if shouldShowAd {
                        Text("Remove ads in iPhone Settings")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                            .opacity(textOpacity)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .onAppear {
            animateCelebration()
        }
    }

    private func handleNavigation(action: @escaping () -> Void) {
        if shouldShowAd {
            pendingAction = action
            adCountdown = 3
            showingAd = true
        } else {
            action()
        }
    }

    private func animateCelebration() {
        // Star bounce in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
            starScale = 1.0
        }

        // Text fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            textOpacity = 1.0
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }
    }
}

// MARK: - Watch Ad View (minimal static ad)
struct WatchAdView: View {
    @Binding var countdown: Int
    let onDismiss: () -> Void

    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 8) {
            Text("Ad")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.yellow)

            Text("Keep Practicing!")
                .font(.headline)
                .foregroundColor(.white)

            Text("Spelling makes you smarter")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            if countdown > 0 {
                Text("\(countdown)...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            } else {
                Button {
                    timer?.invalidate()
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
            }
        }
        .padding()
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    createParticles(in: geo.size)
                }
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.cyan, .white, .blue, .mint, .pink, .purple]

        for i in 0..<20 {
            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .cyan,
                size: CGFloat.random(in: 4...8),
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                opacity: 1.0
            )
            particles.append(particle)
        }

        // Animate particles outward
        withAnimation(.easeOut(duration: 1.5)) {
            for i in particles.indices {
                particles[i].position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                particles[i].opacity = 0
            }
        }

        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particles.removeAll()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

struct LevelCompleteView_Previews: PreviewProvider {
    static var previews: some View {
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

            LevelCompleteView(viewModel: GameViewModel(), level: 1)
                .environmentObject(AppState())
        }
    }
}
