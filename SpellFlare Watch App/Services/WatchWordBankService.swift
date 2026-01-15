//
//  WatchWordBankService.swift
//  SpellFlare Watch App
//
//  Word bank service for watchOS with bundled words for standalone mode.
//

import Foundation

class WatchWordBankService {
    static let shared = WatchWordBankService()

    // MARK: - Synced Words (from iPhone)
    private var syncedWords: [Int: [String]] = [:]

    // MARK: - Bundled Words for Standalone Mode (Grades 1-3)
    private let standaloneWords: [Int: [String]] = [
        // Grade 1 - Simple 3-4 letter words
        1: [
            "cat", "dog", "sun", "run", "big", "red", "hat", "sit", "cup", "bed",
            "mom", "dad", "pet", "top", "hot", "not", "got", "lot", "pot", "dot",
            "map", "cap", "tap", "nap", "lap", "sap", "gap", "rap", "zap", "pan",
            "man", "can", "ran", "fan", "tan", "van", "ban", "den", "hen", "men",
            "pen", "ten", "wet", "set", "let", "get", "net", "met", "yet", "jet"
        ],

        // Grade 2 - 4-5 letter words
        2: [
            "ball", "tree", "book", "fish", "bird", "cake", "play", "jump", "swim", "sing",
            "read", "walk", "talk", "look", "cook", "took", "good", "wood", "food", "moon",
            "room", "soon", "noon", "door", "poor", "more", "four", "your", "pour", "sour",
            "hour", "our", "out", "about", "shout", "mouth", "south", "house", "mouse", "blouse",
            "cloud", "proud", "loud", "found", "round", "sound", "ground", "brown", "crown", "frown"
        ],

        // Grade 3 - 5-6 letter words
        3: [
            "friend", "school", "write", "plant", "cloud", "train", "chair", "think", "sleep", "dream",
            "beach", "reach", "teach", "peach", "each", "much", "such", "touch", "watch", "catch",
            "match", "patch", "batch", "latch", "hatch", "scratch", "stretch", "switch", "twitch", "stitch",
            "bright", "right", "light", "night", "might", "sight", "fight", "tight", "flight", "knight",
            "brought", "bought", "thought", "caught", "taught", "daughter", "laughter", "after", "water", "father"
        ]
    ]

    // MARK: - Get Words

    /// Get words for a level, using synced words if available, otherwise bundled
    func getWords(grade: Int, level: Int, count: Int) -> [WatchWord] {
        // Calculate difficulty based on grade and level
        let baseDifficulty = grade
        let levelBonus = (level - 1) / 10
        let difficulty = min(baseDifficulty + levelBonus, 12)

        // Get word list - prefer synced, fallback to standalone
        let wordList: [String]
        if let synced = syncedWords[grade], !synced.isEmpty {
            wordList = synced
        } else if let bundled = standaloneWords[grade] {
            wordList = bundled
        } else if let bundled = standaloneWords[1] {
            // Fallback to grade 1 if grade not available
            wordList = bundled
        } else {
            // Emergency fallback
            wordList = ["cat", "dog", "sun", "run", "big", "red", "hat", "sit", "cup", "bed"]
        }

        // Shuffle and pick words
        let shuffled = wordList.shuffled()
        let selected = Array(shuffled.prefix(count))

        return selected.map { WatchWord(text: $0, difficulty: difficulty) }
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
}
