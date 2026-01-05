#!/usr/bin/env python3
"""
Generate all audio files for SpellFlare using Coqui TTS.
This script creates pre-generated audio files that will be bundled with the app.
"""

import os
import json
from pathlib import Path
import time

try:
    from TTS.api import TTS
except ImportError:
    print("❌ TTS library not found!")
    print("   Please install: pip install TTS")
    exit(1)

# Configuration
OUTPUT_DIR = "../spelling-bee iOS App/Resources/Audio"
MODEL = "tts_models/en/ljspeech/tacotron2-DDC"
SAMPLE_RATE = 22050  # Default for the model

class AudioGenerator:
    def __init__(self):
        print("🔧 Initializing Coqui TTS...")
        try:
            self.tts = TTS(model_name=MODEL, progress_bar=False)
            print(f"   Model: {MODEL}")
            print(f"   Sample rate: {SAMPLE_RATE} Hz")
        except Exception as e:
            print(f"❌ Failed to initialize TTS: {e}")
            raise

        self.output_dir = Path(OUTPUT_DIR)
        self.generated_count = 0

    def generate_word_audio(self, word, difficulty):
        """Generate full word pronunciation"""
        output_path = self.output_dir / f"words/difficulty_{difficulty}/{word}.wav"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.tts.tts_to_file(
                text=word,
                file_path=str(output_path)
            )
            self.generated_count += 1
            return True
        except Exception as e:
            print(f"      ❌ Failed to generate {word}: {e}")
            return False

    def generate_spelled_audio(self, word, difficulty):
        """Generate letter-by-letter spelling with pauses"""
        # Add commas between letters for natural pauses
        letters = ", ".join(word.upper())
        output_path = self.output_dir / f"spelling/difficulty_{difficulty}/{word}_spelled.wav"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.tts.tts_to_file(
                text=letters,
                file_path=str(output_path)
            )
            self.generated_count += 1
            return True
        except Exception as e:
            print(f"      ❌ Failed to generate {word}_spelled: {e}")
            return False

    def generate_letter_audio(self, letter):
        """Generate individual letter pronunciation"""
        output_path = self.output_dir / f"letters/{letter.lower()}.wav"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.tts.tts_to_file(
                text=letter.upper(),
                file_path=str(output_path)
            )
            self.generated_count += 1
            return True
        except Exception as e:
            print(f"      ❌ Failed to generate letter {letter}: {e}")
            return False

    def generate_feedback_audio(self, text, category, filename):
        """Generate feedback message audio"""
        output_path = self.output_dir / f"feedback/{category}/{filename}.wav"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.tts.tts_to_file(
                text=text,
                file_path=str(output_path)
            )
            self.generated_count += 1
            return True
        except Exception as e:
            print(f"      ❌ Failed to generate {filename}: {e}")
            return False

    def generate_instruction_audio(self, text, filename):
        """Generate instruction prompt audio"""
        output_path = self.output_dir / f"instructions/{filename}.wav"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.tts.tts_to_file(
                text=text,
                file_path=str(output_path)
            )
            self.generated_count += 1
            return True
        except Exception as e:
            print(f"      ❌ Failed to generate {filename}: {e}")
            return False

def main():
    start_time = time.time()

    print("=" * 60)
    print("🎙️  SpellFlare Audio Generation Pipeline")
    print("=" * 60)
    print()

    # Check if word bank exists
    if not os.path.exists('word_bank.json'):
        print("❌ word_bank.json not found!")
        print("   Please run: python export_word_bank.py")
        return

    # Load word bank
    with open('word_bank.json', 'r') as f:
        word_bank = json.load(f)

    # Convert string keys to integers
    word_bank = {int(k): v for k, v in word_bank.items()}

    # Initialize generator
    generator = AudioGenerator()

    print()
    print("📦 Phase 1: Generating Word Pronunciations")
    print("-" * 60)

    total_words = sum(len(words) for words in word_bank.values())
    processed = 0

    for difficulty, words in sorted(word_bank.items()):
        print(f"   Difficulty {difficulty:2d}: {len(words)} words")
        for word in words:
            processed += 1
            percent = (processed / total_words) * 100
            print(f"      [{processed:3d}/{total_words}] ({percent:5.1f}%) {word:<25}", end='\r')
            generator.generate_word_audio(word, difficulty)
        print()  # New line after each difficulty

    print()
    print("📝 Phase 2: Generating Letter-by-Letter Spelling")
    print("-" * 60)

    processed = 0
    for difficulty, words in sorted(word_bank.items()):
        print(f"   Difficulty {difficulty:2d}: {len(words)} words")
        for word in words:
            processed += 1
            percent = (processed / total_words) * 100
            print(f"      [{processed:3d}/{total_words}] ({percent:5.1f}%) {word}_spelled", end='\r')
            generator.generate_spelled_audio(word, difficulty)
        print()

    print()
    print("🔤 Phase 3: Generating Individual Letters")
    print("-" * 60)

    for i, letter in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 1):
        print(f"      [{i:2d}/26] {letter}", end='\r')
        generator.generate_letter_audio(letter)
    print()

    print()
    print("💬 Phase 4: Generating Feedback Messages")
    print("-" * 60)

    feedback_map = {
        'success': [
            ('Great job!', 'great_job'),
            ('Excellent!', 'excellent'),
            ('You got it!', 'you_got_it'),
            ('Perfect!', 'perfect'),
            ('Amazing!', 'amazing'),
            ('Wonderful!', 'wonderful')
        ],
        'encouragement': [
            ('Nice try!', 'nice_try'),
            ('Almost there!', 'almost_there'),
            ('Keep trying!', 'keep_trying'),
            ("Don't give up!", 'dont_give_up')
        ],
        'system': [
            ('The correct spelling is', 'correct_spelling_is'),
            ('Congratulations! You completed the level!', 'level_complete')
        ]
    }

    for category, messages in feedback_map.items():
        print(f"   {category.capitalize()}:")
        for text, filename in messages:
            print(f"      - {filename}")
            generator.generate_feedback_audio(text, category, filename)

    print()
    print("📢 Phase 5: Generating Instruction Prompts")
    print("-" * 60)

    instructions = [
        ('Listen carefully!', 'listen_carefully'),
        ('Spell the word out loud', 'spell_out_loud'),
        ('Say each letter', 'say_each_letter'),
        ('Tap to speak', 'tap_to_speak'),
        ('Type the spelling', 'type_spelling')
    ]

    for text, filename in instructions:
        print(f"      - {filename}")
        generator.generate_instruction_audio(text, filename)

    # Summary
    elapsed_time = time.time() - start_time
    minutes = int(elapsed_time // 60)
    seconds = int(elapsed_time % 60)

    print()
    print("=" * 60)
    print("✅ Audio Generation Complete!")
    print("=" * 60)
    print(f"   Total files generated: {generator.generated_count}")
    print(f"   Time elapsed: {minutes}m {seconds}s")
    print(f"   Output directory: {OUTPUT_DIR}")
    print()
    print("Next steps:")
    print("   1. Run: python validate_audio.py")
    print("   2. Run: python check_completeness.py")
    print("   3. Add Audio folder to Xcode project")
    print()

if __name__ == "__main__":
    main()
