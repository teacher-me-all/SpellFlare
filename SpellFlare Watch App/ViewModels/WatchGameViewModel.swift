//
//  WatchGameViewModel.swift
//  SpellFlare Watch App
//
//  Manages game session state for the Watch app.
//

import SwiftUI

// MARK: - Game Phase
enum WatchGamePhase {
    case presenting     // Word is being spoken
    case spelling       // User is spelling
    case feedback       // Showing correct/incorrect
}

// MARK: - Feedback Type
enum WatchFeedbackType {
    case correct
    case incorrect
}

// MARK: - Word Model (Watch-specific, lightweight)
struct WatchWord: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let difficulty: Int
}

// MARK: - Game Session
class WatchGameSession {
    let level: Int
    let grade: Int
    private(set) var words: [WatchWord]
    private(set) var currentIndex: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var incorrectCount: Int = 0
    let requiredCorrect = 10

    init(level: Int, grade: Int, words: [WatchWord]) {
        self.level = level
        self.grade = grade
        self.words = words
    }

    var currentWord: WatchWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    var isComplete: Bool {
        correctCount >= requiredCorrect || currentIndex >= words.count
    }

    var progress: Double {
        Double(currentIndex) / Double(words.count)
    }

    func markCorrect() {
        correctCount += 1
        currentIndex += 1
    }

    func markIncorrect() {
        incorrectCount += 1
        currentIndex += 1
    }
}

// MARK: - Game View Model
@MainActor
class WatchGameViewModel: ObservableObject {
    // MARK: - Published State
    @Published var phase: WatchGamePhase = .presenting
    @Published var session: WatchGameSession?
    @Published var feedbackType: WatchFeedbackType?
    @Published var userSpelling = ""
    @Published var retryCount = 0

    // MARK: - Services
    private let speechService = WatchSpeechService.shared
    private let audioService = WatchAudioService.shared
    private let wordBank = WatchWordBankService.shared

    // MARK: - Computed Properties
    var currentWord: WatchWord? {
        session?.currentWord
    }

    var correctCount: Int {
        session?.correctCount ?? 0
    }

    var progress: Double {
        session?.progress ?? 0
    }

    var isLevelComplete: Bool {
        session?.isComplete ?? false
    }

    // MARK: - Game Flow
    func startLevel(level: Int, grade: Int) {
        let words = wordBank.getWords(grade: grade, level: level, count: 15)
        session = WatchGameSession(level: level, grade: grade, words: words)

        phase = .presenting
        presentCurrentWord()
    }

    func presentCurrentWord() {
        guard let word = currentWord else {
            checkLevelCompletion()
            return
        }

        retryCount = 0
        phase = .presenting
        speechService.setCurrentWord(word.text)

        // Play word audio
        audioService.playWord(word.text, difficulty: word.difficulty)
    }

    func repeatWord() {
        guard let word = currentWord else { return }
        audioService.playWord(word.text, difficulty: word.difficulty)
    }

    func startSpelling() {
        phase = .spelling
        userSpelling = ""
        speechService.startListening()
    }

    func submitSpelling(_ spelling: String) {
        speechService.stopListening()
        userSpelling = spelling

        guard let word = currentWord else { return }

        let isCorrect = validateSpelling(spelling, correctWord: word.text)

        if isCorrect {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    }

    private func validateSpelling(_ input: String, correctWord: String) -> Bool {
        let normalizedInput = input
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        let normalizedCorrect = correctWord.lowercased()

        return normalizedInput == normalizedCorrect
    }

    private func handleCorrectAnswer() {
        session?.markCorrect()
        feedbackType = .correct
        phase = .feedback

        audioService.playFeedback(.correct)

        // Auto-advance after delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.advanceToNextWord()
            }
        }
    }

    private func handleIncorrectAnswer() {
        feedbackType = .incorrect
        phase = .feedback
        retryCount += 1

        audioService.playFeedback(.incorrect)
    }

    func retry() {
        feedbackType = nil
        userSpelling = ""
        phase = .presenting
        presentCurrentWord()
    }

    func giveUp() {
        session?.markIncorrect()
        advanceToNextWord()
    }

    private func advanceToNextWord() {
        feedbackType = nil
        userSpelling = ""

        if isLevelComplete {
            phase = .feedback  // Will trigger level complete screen
        } else if currentWord != nil {
            phase = .presenting
            presentCurrentWord()
        }
    }

    private func checkLevelCompletion() {
        if isLevelComplete {
            phase = .feedback
        }
    }

    func cleanup() {
        speechService.stopListening()
        audioService.stop()
    }

    var completedLevel: Int {
        session?.level ?? 0
    }

    var finalScore: Int {
        session?.correctCount ?? 0
    }
}
