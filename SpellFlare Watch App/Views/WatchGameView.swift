//
//  WatchGameView.swift
//  SpellFlare Watch App
//
//  Main game screen containing word presentation, spelling, and feedback.
//

import SwiftUI

struct WatchGameView: View {
    @EnvironmentObject var appState: WatchAppState
    @EnvironmentObject var syncHelper: WatchSyncHelper
    @StateObject private var viewModel = WatchGameViewModel()

    let level: Int

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
            GameHeaderView(
                level: level,
                correctCount: viewModel.correctCount,
                progress: viewModel.progress,
                onExit: { appState.navigateToHome() }
            )

            Spacer()

            // Main content based on phase
            switch viewModel.phase {
            case .presenting:
                WordPresentingView(viewModel: viewModel)

            case .spelling:
                SpellingInputView(viewModel: viewModel)

            case .feedback:
                if viewModel.isLevelComplete {
                    // Level complete - transition to complete screen
                    Color.clear
                        .onAppear {
                            appState.showLevelComplete(
                                level: viewModel.completedLevel,
                                score: viewModel.finalScore
                            )
                            syncHelper.sendLevelCompleted(level)
                        }
                } else {
                    FeedbackResultView(viewModel: viewModel)
                }
            }

            Spacer()
        }
        .onAppear {
            let grade = syncHelper.profile?.grade ?? 1
            viewModel.startLevel(level: level, grade: grade)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Game Header
struct GameHeaderView: View {
    let level: Int
    let correctCount: Int
    let progress: Double
    let onExit: () -> Void

    var body: some View {
        HStack {
            // Exit button
            Button(action: onExit) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)

            Spacer()

            // Level
            Text("Lvl \(level)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Score
            Text("\(correctCount)/10")
                .font(.caption)
                .foregroundColor(.cyan)
        }
        .padding(.horizontal)
        .padding(.top, 4)

        // Progress bar
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)

                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: geo.size.width * progress, height: 4)
            }
            .cornerRadius(2)
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

// MARK: - Word Presenting View
struct WordPresentingView: View {
    @ObservedObject var viewModel: WatchGameViewModel
    @ObservedObject var audioService = WatchAudioService.shared

    var body: some View {
        VStack(spacing: 16) {
            // Speaker animation
            Image(systemName: audioService.isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
                .font(.system(size: 40))
                .foregroundColor(.cyan)

            Text("Listen...")
                .font(.headline)
                .foregroundColor(.secondary)

            // Action buttons
            HStack(spacing: 12) {
                // Repeat button
                Button {
                    viewModel.repeatWord()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)

                // Go/Spell button
                Button {
                    viewModel.startSpelling()
                } label: {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Spell")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.cyan)
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Spelling Input View
struct SpellingInputView: View {
    @ObservedObject var viewModel: WatchGameViewModel
    @ObservedObject var speechService = WatchSpeechService.shared

    @State private var showKeyboardInput = false
    @State private var keyboardText = ""

    var body: some View {
        VStack(spacing: 12) {
            // Mic button
            Button {
                if speechService.isListening {
                    speechService.stopListening()
                } else {
                    speechService.startListening()
                }
            } label: {
                ZStack {
                    // Pulse animation when listening
                    if speechService.isListening {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .scaleEffect(speechService.isListening ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: speechService.isListening)
                    }

                    Circle()
                        .fill(speechService.isListening ? Color.red : Color.cyan)
                        .frame(width: 60, height: 60)

                    Image(systemName: speechService.isListening ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            // Recognized letters
            if !speechService.recognizedLetters.isEmpty {
                Text(formatLetters(speechService.recognizedLetters))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            // Status text
            Text(speechService.isListening ? "Listening..." : "Tap mic to spell")
                .font(.caption)
                .foregroundColor(.secondary)

            // Submit button (when we have letters)
            if !speechService.recognizedLetters.isEmpty && !speechService.isListening {
                Button {
                    viewModel.submitSpelling(speechService.recognizedLetters)
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            // Keyboard fallback (small button)
            Button {
                showKeyboardInput = true
            } label: {
                HStack {
                    Image(systemName: "keyboard")
                    Text("Type")
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showKeyboardInput) {
            KeyboardInputSheet(
                text: $keyboardText,
                onSubmit: {
                    viewModel.submitSpelling(keyboardText)
                    showKeyboardInput = false
                    keyboardText = ""
                }
            )
        }
    }

    private func formatLetters(_ letters: String) -> String {
        letters.map { String($0) }.joined(separator: " - ")
    }
}

// MARK: - Keyboard Input Sheet
struct KeyboardInputSheet: View {
    @Binding var text: String
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Type spelling")
                .font(.headline)

            TextField("Spell here", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("Submit") {
                onSubmit()
            }
            .disabled(text.isEmpty)
        }
        .padding()
    }
}

// MARK: - Feedback Result View
struct FeedbackResultView: View {
    @ObservedObject var viewModel: WatchGameViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Result icon
            if viewModel.feedbackType == .correct {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }

            // Word display
            if let word = viewModel.currentWord {
                Text(word.text.uppercased())
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            // Action buttons
            if viewModel.feedbackType == .incorrect {
                HStack(spacing: 12) {
                    Button {
                        viewModel.retry()
                    } label: {
                        Text("Retry")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.cyan)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.giveUp()
                    } label: {
                        Text("Skip")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    WatchGameView(level: 1)
        .environmentObject(WatchAppState())
        .environmentObject(WatchSyncHelper.shared)
}
