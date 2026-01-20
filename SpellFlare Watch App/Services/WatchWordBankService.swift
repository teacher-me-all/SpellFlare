//
//  WatchWordBankService.swift
//  SpellFlare Watch App
//
//  Word bank service for watchOS with bundled words for standalone mode.
//

import Foundation

// MARK: - Word Sentence Model
struct WatchWordSentence: Identifiable {
    let id = UUID()
    let word: String
    let difficulty: Int
    let sentenceNumber: Int  // 1, 2, or 3

    var displayLabel: String {
        "Sentence \(sentenceNumber)"
    }
}

class WatchWordBankService {
    static let shared = WatchWordBankService()

    // MARK: - Synced Words (from iPhone)
    private var syncedWords: [Int: [String]] = [:]

    // MARK: - Bundled Words for Standalone Mode (Grades 1-7, Difficulty 1-12)
    // NOTE: All words have audio files in Audio/Lisa/words/difficulty_X/
    private let standaloneWords: [Int: [String]] = [
        // Difficulty 1 - Grade 1 simple words
        1: ["cat", "dog", "sun", "run", "big", "red", "hat", "sit", "cup", "bed",
            "mom", "dad", "pet", "fun", "hot", "top", "box", "fox", "yes", "bus"],

        // Difficulty 2 - Grade 2 words
        2: ["ball", "tree", "book", "fish", "bird", "cake", "play", "jump", "swim", "blue",
            "green", "happy", "water", "apple", "house", "mouse", "sleep", "dream", "smile", "light"],

        // Difficulty 3 - Grade 3 words
        3: ["friend", "school", "write", "plant", "cloud", "train", "beach", "clean", "bring", "thing",
            "laugh", "watch", "catch", "match", "patch", "lunch", "bench", "branch", "crunch", "french"],

        // Difficulty 4 - Grade 4 words
        4: ["beautiful", "different", "important", "together", "remember", "between", "another", "through", "thought", "brought",
            "daughter", "neighbor", "weight", "height", "straight", "caught", "taught", "bought", "fought", "sought"],

        // Difficulty 5 - Grade 5 words
        5: ["character", "paragraph", "adventure", "attention", "celebrate", "community", "continue", "describe", "discover", "education",
            "especially", "experience", "favorite", "government", "important", "interested", "knowledge", "literature", "necessary", "particular"],

        // Difficulty 6 - Grade 6 words
        6: ["accomplish", "throughout", "appreciate", "atmosphere", "boundaries", "challenge", "commercial", "competition", "concentrate", "conscience",
            "consequence", "consistent", "demonstrate", "development", "environment", "essentially", "exaggerate", "explanation", "extraordinary", "fascinating"],

        // Difficulty 7 - Grade 7 words
        7: ["accommodate", "achievement", "acknowledge", "acquaintance", "advertisement", "anniversary", "anticipation", "appreciation", "approximately", "archaeological",
            "argumentative", "autobiography", "bibliography", "characteristic", "chronological", "circumstances", "classification", "collaboration", "commemorate", "communication"],

        // Difficulty 8 - Advanced (higher levels)
        8: ["abbreviation", "acceleration", "accessibility", "accomplishment", "accountability", "acknowledgement", "administration", "alphabetically", "announcements", "archaeological",
            "assassination", "authentication", "autobiography", "biodegradable", "characteristics", "circumference", "classification", "commercialize", "communication", "comprehensive"],

        // Difficulty 9 - Advanced
        9: ["accommodation", "accomplishment", "acknowledgment", "administration", "alphabetically", "announcements", "approximately", "archaeological", "authentication", "autobiography",
            "biodegradable", "characteristics", "chronological", "circumference", "classification", "collaboration", "commercialize", "communication", "comprehensive", "confederation"],

        // Difficulty 10 - Expert
        10: ["conscientious", "correspondence", "discrimination", "electromagnetic", "entrepreneurial", "environmental", "fundamentalism", "hallucination", "hospitalization", "hypothetically",
             "identification", "implementation", "impressionable", "incomprehensible", "individualism", "industrialization", "infrastructure", "institutionalize", "instrumentation", "intellectualism"],

        // Difficulty 11 - Expert
        11: ["acknowledgeable", "characterization", "circumstantial", "commercialization", "compartmentalize", "comprehensibility", "conceptualization", "confidentiality", "congratulations", "conscientiously",
             "constitutionality", "contemporaneous", "conventionalize", "correspondence", "counterproductive", "crystallization", "decentralization", "demilitarization", "democratization", "departmentalize"],

        // Difficulty 12 - Master
        12: ["autobiographical", "characteristically", "compartmentalization", "comprehensively", "conceptualization", "confidentiality", "congratulatory", "conscientiously", "constitutionally", "contemporaneously",
             "conventionally", "correspondingly", "counterproductively", "crystallographic", "decentralization", "demilitarization", "democratization", "departmentalization", "deterministically", "developmentally"]
    ]

    // MARK: - Get Words

    /// Get words for a level, using synced words if available, otherwise bundled
    func getWords(grade: Int, level: Int, count: Int) -> [WatchWord] {
        // Calculate difficulty based on grade and level (matches iOS logic)
        let baseDifficulty = grade
        let levelBonus = (level - 1) / 10
        let difficulty = min(baseDifficulty + levelBonus, 12)

        // Track words with their actual source difficulty (matches iOS logic)
        var availableWords: [(text: String, difficulty: Int)] = []

        // Get words from difficulty range (current difficulty ± 1)
        for diff in max(1, difficulty - 1)...min(difficulty + 1, 12) {
            if let synced = syncedWords[diff], !synced.isEmpty {
                for word in synced {
                    availableWords.append((text: word, difficulty: diff))
                }
            } else if let bundled = standaloneWords[diff] {
                for word in bundled {
                    availableWords.append((text: word, difficulty: diff))
                }
            }
        }

        // Emergency fallback if no words found
        if availableWords.isEmpty {
            let fallbackWords = ["cat", "dog", "sun", "run", "big", "red", "hat", "sit", "cup", "bed"]
            for word in fallbackWords {
                availableWords.append((text: word, difficulty: 1))
            }
        }

        // Shuffle and pick words
        let shuffled = availableWords.shuffled()
        let selected = Array(shuffled.prefix(count))

        // Create WatchWord objects with correct difficulty for each word
        return selected.map { WatchWord(text: $0.text, difficulty: $0.difficulty) }
    }

    // MARK: - Sync Words from iPhone

    /// Update word list from synced data
    func updateSyncedWords(grade: Int, words: [String]) {
        syncedWords[grade] = words
    }

    /// Clear synced words (for testing or reset)
    func clearSyncedWords() {
        syncedWords.removeAll()
    }

    // MARK: - Availability Check

    /// Check if a grade is available (has words)
    func isGradeAvailable(_ grade: Int) -> Bool {
        return syncedWords[grade] != nil || standaloneWords[grade] != nil
    }

    /// Get available grades
    var availableGrades: [Int] {
        var grades = Set(standaloneWords.keys)
        grades.formUnion(syncedWords.keys)
        return Array(grades).sorted()
    }

    /// Check if running in standalone mode (no synced words)
    var isStandaloneMode: Bool {
        return syncedWords.isEmpty
    }

    // MARK: - Sentences

    /// Get sentences for a word (sentences 1-3)
    func getSentences(for word: WatchWord) -> [WatchWordSentence] {
        return (1...3).map { sentenceNum in
            WatchWordSentence(
                word: word.text,
                difficulty: word.difficulty,
                sentenceNumber: sentenceNum
            )
        }
    }
}
