//
//  WatchAudioService.swift
//  SpellFlare Watch App
//
//  Audio playback service for watchOS using AVAudioPlayer.
//

import Foundation
import AVFoundation
import WatchKit

// MARK: - Feedback Types
enum WatchFeedbackAudioType {
    case correct
    case incorrect
    case levelComplete

    var folder: String {
        switch self {
        case .correct: return "success"
        case .incorrect: return "encouragement"
        case .levelComplete: return "system"
        }
    }

    var files: [String] {
        switch self {
        case .correct:
            return ["great_job", "excellent", "perfect", "amazing", "wonderful", "you_got_it"]
        case .incorrect:
            return ["nice_try", "keep_trying", "almost_there", "dont_give_up"]
        case .levelComplete:
            return ["level_complete"]
        }
    }

    var randomFile: String {
        files.randomElement() ?? files[0]
    }
}

@MainActor
class WatchAudioService: ObservableObject {
    static let shared = WatchAudioService()

    @Published var isPlaying = false

    private var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?

    // MARK: - Initialization
    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Word Playback
    func playWord(_ word: String, difficulty: Int, completion: (() -> Void)? = nil) {
        let path = "Audio/Lisa/words/difficulty_\(difficulty)/\(word.lowercased())"
        play(path: path, completion: completion)
    }

    // MARK: - Spelling Playback
    func playSpelling(_ word: String, difficulty: Int, completion: (() -> Void)? = nil) {
        let path = "Audio/Lisa/spelling/difficulty_\(difficulty)/\(word.lowercased())_spelled"
        play(path: path, completion: completion)
    }

    // MARK: - Letter Playback
    func playLetter(_ letter: String, completion: (() -> Void)? = nil) {
        let path = "Audio/Lisa/letters/\(letter.lowercased())"
        play(path: path, completion: completion)
    }

    // MARK: - Sentence Playback
    func playSentence(_ word: String, difficulty: Int, number: Int, completion: (() -> Void)? = nil) {
        let path = "Audio/Lisa/sentences/difficulty_\(difficulty)/\(word.lowercased())_sentence\(number)"
        play(path: path, completion: completion)
    }

    // MARK: - Feedback Playback
    func playFeedback(_ type: WatchFeedbackAudioType, completion: (() -> Void)? = nil) {
        let file = type.randomFile
        let path = "Audio/Lisa/feedback/\(type.folder)/\(file)"
        play(path: path, completion: completion)
    }

    // MARK: - Core Playback
    private func play(path: String, completion: (() -> Void)?) {
        stop()

        // Try .wav first, then .mp3
        guard let url = findAudioFile(path: path) else {
            print("Audio not found: \(path)")
            // Play haptic feedback as fallback
            WKInterfaceDevice.current().play(.notification)
            completion?()
            return
        }

        do {
            // Re-configure audio session before playback
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()

            completionHandler = completion
            isPlaying = true

            player?.play()

            // Schedule completion callback
            if let duration = player?.duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) { [weak self] in
                    self?.handlePlaybackComplete()
                }
            }

        } catch {
            print("Playback error: \(error)")
            WKInterfaceDevice.current().play(.notification)
            completion?()
        }
    }

    private func findAudioFile(path: String) -> URL? {
        // Try .wav first
        if let url = Bundle.main.url(forResource: path, withExtension: "wav") {
            return url
        }
        // Then try .mp3
        if let url = Bundle.main.url(forResource: path, withExtension: "mp3") {
            return url
        }
        // Try without extension (in case path already has it)
        if let url = Bundle.main.url(forResource: path, withExtension: nil) {
            return url
        }
        return nil
    }

    private func handlePlaybackComplete() {
        isPlaying = false
        let handler = completionHandler
        completionHandler = nil
        handler?()
    }

    // MARK: - Stop
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        completionHandler = nil
    }

    // MARK: - Haptic Feedback
    func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }

    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    func playFailureHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }
}
