#!/usr/bin/env python3
"""
Validate generated audio files meet technical specifications.
"""

import wave
from pathlib import Path

OUTPUT_DIR = "../spelling-bee iOS App/Resources/Audio"

def validate_audio_file(filepath):
    """Check if audio file meets specifications"""
    try:
        with wave.open(str(filepath), 'r') as wav:
            sample_rate = wav.getframerate()
            channels = wav.getnchannels()
            sample_width = wav.getsampwidth()
            frames = wav.getnframes()
            duration = frames / float(sample_rate)

            # Check specifications
            issues = []

            # Sample rate should be 22050 (TTS default) or 44100
            if sample_rate not in [22050, 44100]:
                issues.append(f"Sample rate: {sample_rate} (expected 22050 or 44100)")

            # Should be mono
            if channels != 1:
                issues.append(f"Channels: {channels} (expected 1 - mono)")

            # Should be 16-bit
            if sample_width != 2:
                issues.append(f"Bit depth: {sample_width * 8}-bit (expected 16-bit)")

            # Check duration (should be > 0.1 seconds and < 30 seconds)
            if duration < 0.1:
                issues.append(f"Duration too short: {duration:.2f}s")
            elif duration > 30:
                issues.append(f"Duration too long: {duration:.2f}s")

            if issues:
                print(f"   ⚠️  {filepath.name}")
                for issue in issues:
                    print(f"      - {issue}")
                return False
            else:
                return True

    except Exception as e:
        print(f"   ❌ {filepath.name}: {e}")
        return False

def validate_all_audio():
    audio_dir = Path(OUTPUT_DIR)

    if not audio_dir.exists():
        print(f"❌ Audio directory not found: {OUTPUT_DIR}")
        print("   Please run generate_audio.py first")
        return False

    print("=" * 60)
    print("🔍 Audio File Validation")
    print("=" * 60)
    print()

    categories = {
        'words': 'Word pronunciations',
        'spelling': 'Letter-by-letter spelling',
        'letters': 'Individual letters',
        'feedback': 'Feedback messages',
        'instructions': 'Instruction prompts'
    }

    total_files = 0
    passed_files = 0
    failed_files = []

    for category, description in categories.items():
        category_path = audio_dir / category
        if not category_path.exists():
            print(f"⚠️  {description}: Directory not found")
            continue

        files = list(category_path.rglob("*.wav"))
        if not files:
            print(f"⚠️  {description}: No files found")
            continue

        print(f"📁 {description}: {len(files)} files")

        category_passed = 0
        for audio_file in files:
            total_files += 1
            if validate_audio_file(audio_file):
                category_passed += 1
                passed_files += 1
            else:
                failed_files.append(str(audio_file))

        if category_passed == len(files):
            print(f"   ✅ All {len(files)} files passed")
        else:
            print(f"   ⚠️  {category_passed}/{len(files)} files passed")
        print()

    # Summary
    print("=" * 60)
    print("📊 Validation Summary")
    print("=" * 60)
    print(f"   Total files checked: {total_files}")
    print(f"   Passed: {passed_files} ({passed_files/total_files*100:.1f}%)")
    print(f"   Failed: {len(failed_files)} ({len(failed_files)/total_files*100:.1f}%)")
    print()

    if failed_files:
        print("❌ Failed files:")
        for f in failed_files[:10]:  # Show first 10
            print(f"   - {f}")
        if len(failed_files) > 10:
            print(f"   ... and {len(failed_files) - 10} more")
        print()
        return False
    else:
        print("✅ All audio files passed validation!")
        print()
        return True

if __name__ == "__main__":
    success = validate_all_audio()
    exit(0 if success else 1)
