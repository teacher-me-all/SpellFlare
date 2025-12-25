//
//  FeedbackView.swift
//  spelling-bee Watch App
//
//  Shows feedback after spelling attempt with animations.
//

import SwiftUI

struct FeedbackView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var animationScale: CGFloat = 0.5
    @State private var animationOpacity: Double = 0

    var isCorrect: Bool {
        viewModel.feedbackType == .correct
    }

    var correctWord: String {
        viewModel.currentWord?.text ?? ""
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // Animated feedback emoji
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.cyan.opacity(0.3) : Color.red.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(animationScale)

                Text(isCorrect ? "🎉" : "😢")
                    .font(.system(size: 50))
                    .scaleEffect(animationScale)
            }
            .opacity(animationOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    animationScale = 1.0
                    animationOpacity = 1.0
                }
            }

            // Feedback message
            Text(isCorrect ? "Great Job!" : "Not quite...")
                .font(.headline)
                .foregroundColor(isCorrect ? .cyan : .white)

            // Show correct spelling after giving up
            if !isCorrect && !viewModel.showRetryOption && !correctWord.isEmpty {
                VStack(spacing: 4) {
                    Text("Correct spelling:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))

                    Text(correctWord.uppercased())
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
            }

            Spacer()

            // Retry/Give Up buttons for incorrect
            if viewModel.showRetryOption {
                HStack(spacing: 8) {
                    Button {
                        viewModel.retry()
                    } label: {
                        Text("Retry")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    .tint(.cyan)

                    Button {
                        viewModel.giveUp()
                    } label: {
                        Text("Give Up")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.3))
                }
            }
        }
        .padding()
    }
}

// MARK: - Animated Stars (for correct answers)
struct AnimatedStars: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.cyan)
                    .offset(
                        x: animate ? CGFloat.random(in: -30...30) : 0,
                        y: animate ? CGFloat.random(in: -40...(-20)) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.0).delay(Double(i) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Bounce Animation Modifier
struct BounceEffect: ViewModifier {
    @State private var bounce = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bounce ? 1.0 : 0.8)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    bounce = true
                }
            }
    }
}

extension View {
    func bounceIn() -> some View {
        modifier(BounceEffect())
    }
}

struct FeedbackView_Previews: PreviewProvider {
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

            FeedbackView(viewModel: GameViewModel())
        }
    }
}
