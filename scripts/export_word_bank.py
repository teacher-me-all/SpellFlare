#!/usr/bin/env python3
"""
Export word bank from Swift code to JSON for audio generation.
"""

import json

# Word bank extracted from WordBankService.swift
word_bank = {
    1: ["cat", "dog", "sun", "run", "big", "red", "hat", "sit", "cup", "bed",
        "mom", "dad", "pet", "fun", "hot", "top", "box", "fox", "yes", "bus"],
    2: ["ball", "tree", "book", "fish", "bird", "cake", "play", "jump", "swim", "blue",
        "green", "happy", "water", "apple", "house", "mouse", "sleep", "dream", "smile", "light"],
    3: ["friend", "school", "write", "plant", "cloud", "train", "beach", "clean", "bring", "thing",
        "laugh", "watch", "catch", "match", "patch", "lunch", "bench", "branch", "crunch", "french"],
    4: ["beautiful", "different", "important", "together", "remember", "between", "another", "through", "thought", "brought",
        "daughter", "neighbor", "weight", "height", "straight", "caught", "taught", "bought", "fought", "sought"],
    5: ["character", "paragraph", "adventure", "attention", "celebrate", "community", "continue", "describe", "discover", "education",
        "especially", "experience", "favorite", "government", "important", "interested", "knowledge", "literature", "necessary", "particular"],
    6: ["accomplish", "throughout", "appreciate", "atmosphere", "boundaries", "challenge", "commercial", "competition", "concentrate", "conscience",
        "consequence", "consistent", "demonstrate", "development", "environment", "essentially", "exaggerate", "explanation", "extraordinary", "fascinating"],
    7: ["accommodate", "achievement", "acknowledge", "acquaintance", "advertisement", "anniversary", "anticipation", "appreciation", "approximately", "archaeological",
        "argumentative", "autobiography", "bibliography", "characteristic", "chronological", "circumstances", "classification", "collaboration", "commemorate", "communication"],
    8: ["abbreviation", "acceleration", "accessibility", "accomplishment", "accountability", "acknowledgement", "administration", "alphabetically", "announcements", "archaeological",
        "assassination", "authentication", "autobiography", "biodegradable", "characteristics", "circumference", "classification", "commercialize", "communication", "comprehensive"],
    9: ["accommodation", "accomplishment", "acknowledgment", "administration", "alphabetically", "announcements", "approximately", "archaeological", "authentication", "autobiography",
        "biodegradable", "characteristics", "chronological", "circumference", "classification", "collaboration", "commercialize", "communication", "comprehensive", "confederation"],
    10: ["conscientious", "correspondence", "discrimination", "electromagnetic", "entrepreneurial", "environmental", "fundamentalism", "hallucination", "hospitalization", "hypothetically",
         "identification", "implementation", "impressionable", "incomprehensible", "individualism", "industrialization", "infrastructure", "institutionalize", "instrumentation", "intellectualism"],
    11: ["acknowledgeable", "characterization", "circumstantial", "commercialization", "compartmentalize", "comprehensibility", "conceptualization", "confidentiality", "congratulations", "conscientiously",
         "constitutionality", "contemporaneous", "conventionalize", "correspondence", "counterproductive", "crystallization", "decentralization", "demilitarization", "democratization", "departmentalize"],
    12: ["autobiographical", "characteristically", "compartmentalization", "comprehensively", "conceptualization", "confidentiality", "congratulatory", "conscientiously", "constitutionally", "contemporaneously",
         "conventionally", "correspondingly", "counterproductively", "crystallographic", "decentralization", "demilitarization", "democratization", "departmentalization", "deterministically", "developmentally"]
}

# Calculate statistics
total_words = sum(len(words) for words in word_bank.values())
unique_words = len(set(word for words in word_bank.values() for word in words))

print("📊 Word Bank Statistics:")
print(f"   Total difficulty levels: {len(word_bank)}")
print(f"   Total words (with duplicates): {total_words}")
print(f"   Unique words: {unique_words}")
print()

# Save to JSON
output_file = 'word_bank.json'
with open(output_file, 'w') as f:
    json.dump(word_bank, f, indent=2)

print(f"✅ Word bank exported to {output_file}")
print(f"   Ready for audio generation!")
