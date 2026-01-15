//
//  WatchSpeechService.swift
//  SpellFlare Watch App
//
//  Speech recognition service optimized for watchOS.
//  Note: Speech framework requires watchOS 10+. For older versions,
//  users must use keyboard input.
//

import Foundation
import AVFoundation

#if canImport(Speech)
import Speech
#endif

// MARK: - Spelling State Machine
enum SpellingState {
    case waitingForFirstLetter  // Ignore full words, wait for valid letter
    case spellingMode           // Accept all letters
}

@MainActor
class WatchSpeechService: NSObject, ObservableObject {
    static let shared = WatchSpeechService()

    // MARK: - Published State
    @Published var recognizedLetters = ""
    @Published var isListening = false
    @Published var spellingState: SpellingState = .waitingForFirstLetter
    @Published var isSpeechAvailable = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    #if canImport(Speech)
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    #endif
    private let audioEngine = AVAudioEngine()
    private var currentWord: String = ""
    private var listeningTimeoutTask: Task<Void, Never>?

    // MARK: - Constants
    private let maxListeningDuration: TimeInterval = 30  // Auto-stop after 30s

    // MARK: - Initialization
    override init() {
        super.init()
        #if canImport(Speech)
        if #available(watchOS 10.0, *) {
            recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            requestAuthorization()
        } else {
            isSpeechAvailable = false
        }
        #else
        isSpeechAvailable = false
        #endif
    }

    // MARK: - Authorization
    func requestAuthorization() {
        #if canImport(Speech)
        if #available(watchOS 10.0, *) {
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.isSpeechAvailable = (status == .authorized)
                    if status != .authorized {
                        self?.errorMessage = "Speech recognition not authorized"
                    }
                }
            }
        }
        #endif
    }

    // MARK: - Configuration
    func setCurrentWord(_ word: String) {
        currentWord = word.uppercased()
        spellingState = .waitingForFirstLetter
        recognizedLetters = ""
    }

    // MARK: - Recognition Control
    func startListening() {
        #if canImport(Speech)
        if #available(watchOS 10.0, *) {
            startListeningInternal()
        } else {
            errorMessage = "Speech recognition requires watchOS 10+"
        }
        #else
        errorMessage = "Speech recognition not available"
        #endif
    }

    #if canImport(Speech)
    @available(watchOS 10.0, *)
    private func startListeningInternal() {
        guard isSpeechAvailable else {
            errorMessage = "Speech recognition not authorized"
            return
        }

        guard !isListening else { return }

        // Stop any existing session
        stopListening()

        // Configure audio session for Watch
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Audio setup failed"
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Failed to create recognition request"
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        // Configure audio engine
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else {
            errorMessage = "Invalid audio format"
            return
        }

        // Install tap with small buffer for responsiveness
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = "Audio engine failed to start"
            return
        }

        // Start recognition task
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let result = result {
                    let text = result.bestTranscription.formattedString
                    if !text.isEmpty {
                        self.processRecognition(text)
                    }
                }

                if let error = error as NSError? {
                    // Error 1110 = no speech, 216 = cancelled - these are normal
                    if error.code != 1110 && error.code != 216 {
                        print("Recognition error: \(error.localizedDescription)")
                    }
                }
            }
        }

        // Set up timeout to auto-stop after maxListeningDuration
        startListeningTimeout()
    }
    #endif

    func stopListening() {
        listeningTimeoutTask?.cancel()
        listeningTimeoutTask = nil

        guard isListening || audioEngine.isRunning else { return }

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)

        #if canImport(Speech)
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil
        #endif

        isListening = false

        // Reset audio session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }

    // MARK: - Timeout Management
    private func startListeningTimeout() {
        listeningTimeoutTask?.cancel()
        listeningTimeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(maxListeningDuration * 1_000_000_000))
            if !Task.isCancelled {
                await MainActor.run {
                    if self.isListening {
                        self.stopListening()
                    }
                }
            }
        }
    }

    // MARK: - State Machine Logic
    private func processRecognition(_ text: String) {
        switch spellingState {
        case .waitingForFirstLetter:
            // Try to extract first valid letter
            if let letter = extractFirstValidLetter(text) {
                spellingState = .spellingMode
                recognizedLetters = letter
            }

        case .spellingMode:
            // Parse all letters from the text
            let letters = parseAllLetters(text)
            if !letters.isEmpty {
                recognizedLetters = letters
            }
        }
    }

    // MARK: - Letter Extraction

    /// Extract the first valid letter from text, skipping the current word
    private func extractFirstValidLetter(_ text: String) -> String? {
        let words = text.uppercased().components(separatedBy: .whitespaces)

        for word in words {
            let trimmed = word.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // Skip if it matches the current word being spelled
            if trimmed == currentWord { continue }

            // Check single letter
            if trimmed.count == 1, trimmed.first?.isLetter == true {
                return trimmed
            }

            // Check phonetic mapping
            if let letter = phoneticMap[trimmed] {
                return letter
            }
        }

        return nil
    }

    /// Parse all letters from text, skipping the current word
    private func parseAllLetters(_ text: String) -> String {
        let words = text.uppercased().components(separatedBy: .whitespaces)
        var result = ""

        for word in words {
            let trimmed = word.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // Skip current word
            if trimmed == currentWord { continue }

            // Single letter
            if trimmed.count == 1, trimmed.first?.isLetter == true {
                result += trimmed
                continue
            }

            // Phonetic mapping
            if let letter = phoneticMap[trimmed] {
                result += letter
            }
        }

        return result
    }

    // MARK: - Phonetic Mappings
    private let phoneticMap: [String: String] = [
        // A
        "AY": "A", "EI": "A",
        // B
        "BE": "B", "BEE": "B",
        // C
        "CE": "C", "SEE": "C", "SEA": "C",
        // D
        "DE": "D", "DEE": "D",
        // E
        "EE": "E",
        // F
        "EF": "F", "EFF": "F",
        // G
        "GE": "G", "GEE": "G", "JEE": "G",
        // H
        "AITCH": "H", "ETCH": "H", "EITCH": "H",
        // I
        "EYE": "I", "AI": "I",
        // J
        "JAY": "J", "JA": "J",
        // K
        "KAY": "K", "KA": "K", "CAY": "K",
        // L
        "EL": "L", "ELL": "L",
        // M
        "EM": "M",
        // N
        "EN": "N",
        // O
        "OH": "O", "OWE": "O",
        // P
        "PE": "P", "PEE": "P",
        // Q
        "CUE": "Q", "QUE": "Q", "QUEUE": "Q",
        // R
        "AR": "R", "ARE": "R",
        // S
        "ES": "S", "ESS": "S",
        // T
        "TE": "T", "TEE": "T",
        // U
        "YOU": "U", "YU": "U", "YEW": "U",
        // V
        "VE": "V", "VEE": "V",
        // W
        "DOUBLE": "W", "DOUBLE-U": "W", "DOUBLEU": "W", "DOUBLEYOU": "W",
        // X
        "EX": "X",
        // Y
        "WHY": "Y", "WI": "Y", "WYE": "Y",
        // Z
        "ZE": "Z", "ZED": "Z", "ZEE": "Z"
    ]
}
