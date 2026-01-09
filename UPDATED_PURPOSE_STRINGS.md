# ✅ Updated Purpose Strings for App Store Compliance

Your Info.plist has been updated with clear, Apple-compliant purpose strings.

---

## What Changed

### ❌ OLD (Rejected by Apple):

**NSMicrophoneUsageDescription:**
```
SpellFlare uses the microphone to listen to your spelling
```

**NSSpeechRecognitionUsageDescription:**
```
SpellFlare needs to hear you spell words
```

**Why rejected:** Too vague, doesn't explain how/why the data is used or what happens with it.

---

### ✅ NEW (Apple-Compliant):

**NSMicrophoneUsageDescription:**
```
SpellFlare uses the microphone to capture your child's voice when they spell words aloud (e.g., saying "C-A-T" for the word "cat"). This allows the app to check if their spelling is correct. Audio is processed in real-time on your device and is never recorded, stored, or shared.
```

**NSSpeechRecognitionUsageDescription:**
```
SpellFlare uses speech recognition to convert your child's spoken spelling into text so the app can verify if the answer is correct. For example, when your child says "C-A-T" aloud, the app checks if that matches the word being practiced. Speech is processed on your device in real-time and is not recorded, stored, or shared with anyone.
```

---

## Why These Will Pass Review

### ✅ Specific Purpose
- Explains it's for checking spelling answers (educational use)
- Provides concrete example: "C-A-T" for "cat"

### ✅ Clear Data Handling
- States audio is processed "in real-time"
- Explicitly says "never recorded, stored, or shared"
- Clarifies processing happens "on your device"

### ✅ Parent-Friendly Language
- Uses "your child's voice" (appropriate for kids app)
- Simple, clear explanation
- No technical jargon

### ✅ Complete Transparency
- No vague phrases like "improve experience"
- Specific about what data is used and how
- Clear about privacy protections

---

## Copy-Paste Format (If Needed)

If you need to manually enter these in Xcode:

### Key: NSMicrophoneUsageDescription
**Value:**
```
SpellFlare uses the microphone to capture your child's voice when they spell words aloud (e.g., saying "C-A-T" for the word "cat"). This allows the app to check if their spelling is correct. Audio is processed in real-time on your device and is never recorded, stored, or shared.
```

### Key: NSSpeechRecognitionUsageDescription
**Value:**
```
SpellFlare uses speech recognition to convert your child's spoken spelling into text so the app can verify if the answer is correct. For example, when your child says "C-A-T" aloud, the app checks if that matches the word being practiced. Speech is processed on your device in real-time and is not recorded, stored, or shared with anyone.
```

---

## How to Verify in Xcode

1. Open `spelling-bee.xcworkspace`
2. Select the project in navigator
3. Select "spelling-bee iOS App" target
4. Go to "Info" tab
5. Look for:
   - **Privacy - Microphone Usage Description**
   - **Privacy - Speech Recognition Usage Description**
6. Verify the new text appears

---

## Next Steps for App Store

1. **Build a new archive:**
   - Product → Archive

2. **Submit for review:**
   - Distribute App → App Store Connect
   - Click "Continue" on dSYM warnings (normal for CocoaPods)

3. **Response to rejection (if asked):**
   - "We have updated the purpose strings to clearly explain that speech recognition is used solely for checking spelling answers in our educational app. Audio is processed in real-time and never recorded or shared."

---

## Privacy Policy Alignment

Make sure your privacy policy (if you have one) also states:
- ✅ Microphone/speech recognition used for spelling verification
- ✅ Audio processed in real-time
- ✅ No recording, storage, or sharing of audio
- ✅ On-device processing only

This matches Apple's Kids Category requirements.

---

## Summary

✅ Purpose strings updated in `Info.plist`
✅ Clear, specific explanation with example
✅ Privacy commitments stated explicitly
✅ Parent-appropriate language
✅ Should pass App Review without questions

You're ready to resubmit!
