#!/usr/bin/env python3
"""
Check that all required audio files have been generated.
"""

import json
from pathlib import Path

OUTPUT_DIR = "../spelling-bee iOS App/Resources/Audio"

def check_completeness():
    audio_dir = Path(OUTPUT_DIR)

    if not audio_dir.exists():
        print(f"❌ Audio directory not found: {OUTPUT_DIR}")
        print("   Please run generate_audio.py first")
        return False

    print("=" * 60)
    print("📋 Audio Completeness Check")
    print("=" * 60)
    print()

    # Load word bank
    if not Path('word_bank.json').exists():
        print("❌ word_bank.json not found!")
        return False

    with open('word_bank.json', 'r') as f:
        word_bank = json.load(f)

    word_bank = {int(k): v for k, v in word_bank.items()}

    missing = []
    found = []

    # Check words
    print("🔤 Checking word pronunciations...")
    for difficulty, words in word_bank.items():
        for word in words:
            word_file = audio_dir / f"words/difficulty_{difficulty}/{word}.wav"
            if not word_file.exists():
                missing.append(f"words/difficulty_{difficulty}/{word}.wav")
            else:
                found.append(word_file)

    total_words = sum(len(words) for words in word_bank.values())
    found_words = total_words - len([m for m in missing if m.startswith('words/')])
    print(f"   Found: {found_words}/{total_words}")
    if found_words < total_words:
        print(f"   ❌ Missing {total_words - found_words} word files")
    else:
        print(f"   ✅ All word files present")
    print()

    # Check spelling
    print("📝 Checking letter-by-letter spelling...")
    for difficulty, words in word_bank.items():
        for word in words:
            spelled_file = audio_dir / f"spelling/difficulty_{difficulty}/{word}_spelled.wav"
            if not spelled_file.exists():
                missing.append(f"spelling/difficulty_{difficulty}/{word}_spelled.wav")
            else:
                found.append(spelled_file)

    found_spelled = total_words - len([m for m in missing if m.startswith('spelling/')])
    print(f"   Found: {found_spelled}/{total_words}")
    if found_spelled < total_words:
        print(f"   ❌ Missing {total_words - found_spelled} spelling files")
    else:
        print(f"   ✅ All spelling files present")
    print()

    # Check letters
    print("🔡 Checking individual letters...")
    letter_count = 0
    for letter in "abcdefghijklmnopqrstuvwxyz":
        letter_file = audio_dir / f"letters/{letter}.wav"
        if not letter_file.exists():
            missing.append(f"letters/{letter}.wav")
        else:
            found.append(letter_file)
            letter_count += 1

    print(f"   Found: {letter_count}/26")
    if letter_count < 26:
        print(f"   ❌ Missing {26 - letter_count} letter files")
    else:
        print(f"   ✅ All letter files present")
    print()

    # Check feedback
    print("💬 Checking feedback messages...")
    feedback_files = {
        'success': ['great_job', 'excellent', 'you_got_it', 'perfect', 'amazing', 'wonderful'],
        'encouragement': ['nice_try', 'almost_there', 'keep_trying', 'dont_give_up'],
        'system': ['correct_spelling_is', 'level_complete']
    }

    feedback_count = 0
    total_feedback = sum(len(files) for files in feedback_files.values())

    for category, files in feedback_files.items():
        for filename in files:
            feedback_file = audio_dir / f"feedback/{category}/{filename}.wav"
            if not feedback_file.exists():
                missing.append(f"feedback/{category}/{filename}.wav")
            else:
                found.append(feedback_file)
                feedback_count += 1

    print(f"   Found: {feedback_count}/{total_feedback}")
    if feedback_count < total_feedback:
        print(f"   ❌ Missing {total_feedback - feedback_count} feedback files")
    else:
        print(f"   ✅ All feedback files present")
    print()

    # Check instructions
    print("📢 Checking instruction prompts...")
    instruction_files = ['listen_carefully', 'spell_out_loud', 'say_each_letter', 'tap_to_speak', 'type_spelling']
    instruction_count = 0

    for filename in instruction_files:
        instruction_file = audio_dir / f"instructions/{filename}.wav"
        if not instruction_file.exists():
            missing.append(f"instructions/{filename}.wav")
        else:
            found.append(instruction_file)
            instruction_count += 1

    print(f"   Found: {instruction_count}/{len(instruction_files)}")
    if instruction_count < len(instruction_files):
        print(f"   ❌ Missing {len(instruction_files) - instruction_count} instruction files")
    else:
        print(f"   ✅ All instruction files present")
    print()

    # Summary
    expected_total = (total_words * 2) + 26 + total_feedback + len(instruction_files)
    found_total = len(found)

    print("=" * 60)
    print("📊 Completeness Summary")
    print("=" * 60)
    print(f"   Expected files: {expected_total}")
    print(f"   Found files: {found_total}")
    print(f"   Missing files: {len(missing)}")
    print()

    if missing:
        print("❌ Missing files:")
        for f in missing[:20]:  # Show first 20
            print(f"   - {f}")
        if len(missing) > 20:
            print(f"   ... and {len(missing) - 20} more")
        print()
        print(f"💡 To regenerate missing files, run: python generate_audio.py")
        print()
        return False
    else:
        print("✅ All required audio files are present!")
        print()
        print("Next steps:")
        print("   1. Add Audio folder to Xcode project")
        print("   2. Implement AudioPlaybackService")
        print("   3. Remove AVSpeechSynthesizer code")
        print()
        return True

if __name__ == "__main__":
    success = check_completeness()
    exit(0 if success else 1)
