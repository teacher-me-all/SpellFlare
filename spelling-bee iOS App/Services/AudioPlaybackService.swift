import AVFoundation

@MainActor
class AudioPlaybackService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlaybackService()

    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?

    private override init() {
        super.init()
    }

    // MARK: - Public Methods

    /// Play word pronunciation
    func playWord(_ word: String, difficulty: Int, completion: (() -> Void)? = nil) {
        let path = "Audio/words/difficulty_\(difficulty)/\(word.lowercased())"
        playAudioFile(path, completion: completion)
    }

    /// Play letter-by-letter spelling
    func playSpelling(_ word: String, difficulty: Int, completion: (() -> Void)? = nil) {
        let path = "Audio/spelling/difficulty_\(difficulty)/\(word.lowercased())_spelled"
        playAudioFile(path, completion: completion)
    }

    /// Play single letter
    func playLetter(_ letter: String, completion: (() -> Void)? = nil) {
        let path = "Audio/letters/\(letter.lowercased())"
        playAudioFile(path, completion: completion)
    }

    /// Play feedback message
    func playFeedback(_ message: String, completion: (() -> Void)? = nil) {
        let filename = mapFeedbackToFile(message)
        let path = "Audio/feedback/\(filename)"
        playAudioFile(path, completion: completion)
    }

    /// Stop current playback
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        completionHandler = nil
    }

    // MARK: - Private Methods

    private func playAudioFile(_ resourcePath: String, completion: (() -> Void)?) {
        // Try to load audio file from bundle
        guard let url = Bundle.main.url(forResource: resourcePath, withExtension: "wav") else {
            print("⚠️ Audio file not found: \(resourcePath).wav")
            completion?()
            return
        }

        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            // Store completion handler
            completionHandler = completion

            // Start playback
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("❌ Failed to play audio: \(error)")
            completion?()
        }
    }

    private func mapFeedbackToFile(_ message: String) -> String {
        let normalized = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Success messages
        if normalized.contains("great job") { return "success/great_job" }
        if normalized.contains("excellent") { return "success/excellent" }
        if normalized.contains("you got it") { return "success/you_got_it" }
        if normalized.contains("perfect") { return "success/perfect" }
        if normalized.contains("amazing") { return "success/amazing" }
        if normalized.contains("wonderful") { return "success/wonderful" }

        // Encouragement messages
        if normalized.contains("nice try") { return "encouragement/nice_try" }
        if normalized.contains("almost there") { return "encouragement/almost_there" }
        if normalized.contains("keep trying") { return "encouragement/keep_trying" }
        if normalized.contains("don't give up") || normalized.contains("dont give up") {
            return "encouragement/dont_give_up"
        }

        // System messages
        if normalized.contains("correct spelling") { return "system/correct_spelling_is" }
        if normalized.contains("completed the level") { return "system/level_complete" }

        // Default fallback
        return "success/great_job"
    }

    // MARK: - AVAudioPlayerDelegate

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            completionHandler?()
            completionHandler = nil
        }
    }
}
