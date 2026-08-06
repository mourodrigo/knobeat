# KnobeatMIDI - macOS MIDI Detection App for Pioneer DDJ-SR

A native macOS diagnostic tool for detecting, monitoring, and testing MIDI devices, with specific support for the Pioneer DDJ-SR DJ controller.

> **🚀 New: Build without Xcode!** You can now build and run this app using just the Swift command-line tools. See [BUILD.md](BUILD.md) for detailed instructions.

## Overview

KnobeatMIDI is Step 1 of a larger multiplatform synthesizer project. This tool provides deep visibility into MIDI I/O and audio routing, helping you understand how the Pioneer DDJ-SR communicates and responds to MIDI messages.

**Current Status:** macOS only, diagnostic/testing phase

## Features

### ✅ MIDI Input Monitoring
- **Device Detection:** Automatically detects and lists all connected MIDI sources
- **DDJ-SR Recognition:** Highlights Pioneer DDJ-SR when connected via USB
- **Real-time Message Logging:** Live scrolling log of all incoming MIDI messages with:
  - Timestamp (millisecond precision)
  - Raw hex bytes (status, data1, data2)
  - Human-readable decoded message (Note On/Off, CC, Pitch Bend, etc.)
  - Channel and velocity information
- **Hot-plug Support:** Automatically updates device list when MIDI devices are connected/disconnected

### ✅ MIDI Output Testing
- **Device Selection:** Choose any MIDI destination for output testing
- **DDJ-SR LED Control:** Pre-configured test patterns for:
  - Performance pads (8 pads per deck × 2 decks)
  - Transport buttons (Play, Cue, Sync)
  - LED colors (Red, Green, Blue, Orange, Yellow)
- **Test Pattern Library:**
  - All Pads Red/Green/Blue
  - Individual deck pad testing
  - Transport button lighting
  - All Off (reset)
- **Manual Message Sender:**
  - Custom channel selection (1-16)
  - Hex input for status byte, data1, data2
  - Direct MIDI message transmission

### ✅ Audio I/O Testing
- **Audio Device Discovery:** Lists all audio input/output devices with channel counts
- **DDJ-SR Audio Interface Detection:** Highlights DDJ-SR audio interface when present
- **Simple Passthrough Test:**
  - Routes selected input to selected output
  - Real-time level meters for input and output
  - Confirms audio path from mixer channels works
- **Level Visualization:** dB-scaled meters with peak indicators

## Requirements

- **macOS:** 13.0 (Ventura) or later
- **Build Tools (choose one):**
  - **Option 1 (No Xcode):** Xcode Command Line Tools with Swift 5.9+ - Install with `xcode-select --install` (~1-2 GB)
  - **Option 2 (Full IDE):** Xcode 15.0 or later from the Mac App Store (~12+ GB)
- **Hardware:** Pioneer DDJ-SR (or any MIDI controller for basic testing)

> **Note:** To build without full Xcode, you need Command Line Tools that include Swift 5.9+. Older macOS versions come with older Swift versions. See [BUILD.md](BUILD.md) for details on updating or working with older macOS versions.

## Building and Running

### Option 1: Build without Xcode (Command Line)

**Prerequisites:**
```bash
# Install Xcode Command Line Tools (required for Swift Package Manager)
xcode-select --install
```

**Quick Start:**
```bash
# Using the build script
./build.sh

# Or using make
make build
make run
```

**Manual Build:**
```bash
# Build with Swift Package Manager
swift build -c release --disable-xctest

# Run the executable
./.build/release/KnobeatMIDI
```

**Install System-Wide:**
```bash
make install
# Then run from anywhere:
KnobeatMIDI
```

**Note:** When built via command line, the app runs as a native executable. The SwiftUI interface will launch normally, but it won't be packaged as a traditional .app bundle unless you use Xcode.

### Option 2: Build with Xcode (Traditional)
1. Open `KnobeatMIDI/KnobeatMIDI.xcodeproj` in Xcode
2. Select your Mac as the build target
3. Press ⌘R to build and run
4. The app will launch and immediately start scanning for MIDI devices

### Build Configuration
- **Language:** Swift 5.9
- **Frameworks:** CoreMIDI, AVFoundation, Core Audio, SwiftUI
- **No external dependencies** - uses only Apple frameworks
- **Build System:** Swift Package Manager (command line) or Xcode (IDE)

## How It Works

### CoreMIDI Setup

The app uses CoreMIDI directly (no third-party MIDI libraries) to understand the raw protocol layer:

1. **MIDI Client Creation:**
   ```swift
   MIDIClientCreateWithBlock(clientName, &client) { notification in
       // Handle device connect/disconnect
   }
   ```

2. **Input Port:**
   - Creates an input port with Protocol 1.0
   - Connects to selected MIDI source
   - Receives MIDI event lists in callback
   - Parses packets into status byte + data bytes
   - Decodes message types (Note, CC, Pitch Bend, etc.)

3. **Output Port:**
   - Creates an output port for sending messages
   - Constructs MIDI packet lists
   - Sends to selected destination via `MIDISend()`

4. **Hot-plug Detection:**
   - Notification handler receives `msgObjectAdded`, `msgObjectRemoved`, `msgSetupChanged`
   - Refreshes device list automatically
   - Maintains connection state

### Audio I/O Architecture

Uses AVFoundation's `AVAudioEngine` for audio routing:

1. **Device Enumeration:**
   - Core Audio API (`AudioObjectGetPropertyData`)
   - Queries `kAudioHardwarePropertyDevices`
   - Reads channel configuration per device

2. **Passthrough:**
   - Configures `AVAudioEngine` input/output nodes
   - Installs tap on input node for level monitoring
   - Connects input → mixer → output
   - Buffer processing extracts RMS levels for meters

3. **Level Metering:**
   - 1024-sample buffers analyzed in real-time
   - Average amplitude converted to visual scale
   - Timer-based decay for smooth display

## Pioneer DDJ-SR MIDI Mappings

### Source: Community Documentation
The DDJ-SR's full MIDI specification is not officially published by Pioneer. These mappings are derived from:
- [Mixxx DJ Software Controller Mappings](https://github.com/mixxxdj/mixxx/tree/main/res/controllers)
- Community reverse-engineering efforts
- Manual testing and observation

### Known Mappings

#### Performance Pads
**Deck A (Channel 1):**
- Pads 1-8: Notes 0x1B through 0x22

**Deck B (Channel 2):**
- Pads 1-8: Notes 0x1B through 0x22

#### Transport Controls
**Deck A (Channel 1):**
- Play: Note 0x0B
- Cue: Note 0x0C
- Sync: Note 0x58

**Deck B (Channel 2):**
- Play: Note 0x0B
- Cue: Note 0x0C
- Sync: Note 0x58

#### LED Colors (Velocity Values for Note messages)
- Off: 0x00
- Dim Red: 0x01
- Red: 0x02
- Dim Green: 0x1A
- Green: 0x1B
- Dim Blue: 0x34
- Blue: 0x35
- Yellow: 0x37
- Orange: 0x0F
- Bright Red: 0x7F

#### VU Meters
- Deck A Level: CC 0x02 on Channel 1
- Deck B Level: CC 0x02 on Channel 2
- *(Note: Exact behavior may vary; these are approximate)*

### What's Missing
Pioneer does not publish:
- Complete SysEx specification for display control (jog wheel OLED)
- VU meter LED mapping details
- Advanced FX button mappings
- Some pad mode switching internals

**Recommendation:** If you need more complete mappings, run Pioneer's Rekordbox DJ software in parallel and use a MIDI monitor (like this app!) to capture the messages it sends. This is a valid reverse-engineering approach for personal/educational use.

## Usage Guide

### Testing MIDI Input
1. Launch KnobeatMIDI
2. Go to "MIDI Input" tab
3. Select your DDJ-SR (or other MIDI device) from the sources list
4. Play notes, turn knobs, press buttons on the controller
5. Watch the message log populate in real-time
6. Observe:
   - Note On/Off messages from pads
   - CC messages from faders/knobs
   - Pitch bend from jog wheels
   - Raw hex alongside decoded text

### Testing MIDI Output (LED Control)
1. Go to "MIDI Output" tab
2. Select DDJ-SR from destinations
3. Click a test pattern button (e.g., "All Pads Red")
4. Watch the DDJ-SR's performance pads light up
5. Try individual pad buttons to test each pad
6. Use "All Off" to reset all LEDs
7. For custom messages, use the Manual Message Sender:
   - Enter channel (1-16)
   - Enter status byte in hex (90 = Note On, B0 = CC)
   - Enter data1 (note/CC number)
   - Enter data2 (velocity/value)
   - Click "Send Message"

### Testing Audio I/O
1. Go to "Audio I/O" tab
2. Select DDJ-SR (or other device) as input
3. Select your desired output device (headphones, speakers, or DDJ-SR)
4. Click "Start Passthrough"
5. Play audio into the DDJ-SR (mixer channels, mic input, etc.)
6. You should hear the audio through the selected output
7. Watch the level meters respond to input signal
8. Click "Stop Passthrough" when done

**Warning:** Audio passthrough introduces latency. This is a diagnostic tool, not a production audio router. Use proper DJ software (Rekordbox, Serato, Traktor, Mixxx) for actual performance.

## Known Issues & Limitations

### Current Limitations
- **macOS Only:** No Windows/Linux support yet (planned for later steps)
- **No Audio Latency Optimization:** Basic passthrough; not suitable for live performance
- **No Config Persistence:** Settings are not saved between sessions
- **No SysEx Support:** SysEx messages are logged but not fully decoded
- **Limited DDJ-SR Display Control:** Jog wheel OLED is not controllable (Pioneer proprietary)

### Troubleshooting

**MIDI devices not showing up:**
- Check USB connection
- Open macOS "Audio MIDI Setup" app to verify device is recognized
- Try unplugging and reconnecting the controller
- Restart the app

**DDJ-SR LEDs not responding:**
- Ensure the DDJ-SR is selected in the "MIDI Output" destinations
- Try the "All Off" pattern first to reset state
- Some LED behaviors depend on the controller's current mode (Hot Cue, Roll, Sampler, etc.)
- Check that the controller is not in MIDI mode lock from another app

**Audio passthrough crackling/distorted:**
- This is expected; the app is not optimized for low-latency audio
- Try different buffer sizes (not currently configurable in this version)
- For production audio, use a proper DAW or DJ software

**App crashes on device connect/disconnect:**
- Please file an issue with crash logs
- This should not happen; hot-plug is supported

## Project Structure

```
KnobeatMIDI/
├── KnobeatMIDI.xcodeproj/       # Xcode project file
└── KnobeatMIDI/
    ├── Info.plist               # App metadata
    ├── Assets.xcassets/         # App icon and assets
    ├── KnobeatMIDIApp.swift     # App entry point
    ├── ContentView.swift        # Main tabbed interface
    ├── Views/
    │   ├── MIDIInputView.swift  # MIDI input monitoring UI
    │   ├── MIDIOutputView.swift # MIDI output testing UI
    │   └── AudioIOView.swift    # Audio I/O testing UI
    └── Models/
        ├── MIDIManager.swift    # CoreMIDI wrapper and message handling
        ├── AudioManager.swift   # Audio device management and passthrough
        └── DDJSRMappings.swift  # Pioneer DDJ-SR control definitions
```

## Open Questions for Step 2

Step 2 will involve building the actual synthesizer engine and mapping MIDI input to sound generation. Open questions:

1. **Synthesis Engine:**
   - Build custom DSP engine in C++ or use an existing framework (JUCE, AudioKit)?
   - Target architecture: additive, subtractive, wavetable, sample-based?

2. **Cross-Platform Strategy:**
   - Port to JUCE for Windows/Linux support?
   - Keep CoreMIDI/AVFoundation for macOS, use separate backends elsewhere?
   - Audio plugin format (VST3, AU, standalone)?

3. **DDJ-SR Integration Depth:**
   - Map jog wheels to synthesis parameters (filter cutoff, pitch, etc.)?
   - Use faders for envelope controls, effects sends?
   - Performance pads for triggering notes, launching clips, or controlling effects?

4. **Audio Routing:**
   - Standalone app or audio plugin?
   - How to handle multi-channel output (deck A/B separate outputs)?
   - Latency targets for live performance?

5. **State Management:**
   - How to save/load presets?
   - MIDI learn for arbitrary parameter mapping?
   - Session persistence?

## Contributing

This is a personal/educational project for understanding MIDI and synthesizer architecture. If you find issues or have suggestions:

1. Check if the DDJ-SR is properly connected and recognized by macOS
2. Test with other MIDI controllers to verify it's not device-specific
3. File an issue with detailed steps to reproduce
4. For DDJ-SR mapping corrections, include:
   - Specific button/control being tested
   - Expected vs. actual MIDI message
   - Your source of truth (Mixxx mapping, manual testing, etc.)

## License

This project is for educational and personal use. The Pioneer DDJ-SR is a trademark of Pioneer DJ Corporation. This software is not affiliated with or endorsed by Pioneer.

## Acknowledgments

- **Mixxx DJ Software:** Community-maintained controller mappings provided invaluable reference
- **Apple Developer Documentation:** CoreMIDI and AVFoundation guides
- **Pioneer DJ Community:** Forum posts and reverse-engineering efforts

---

**Next Steps:** Use this tool to understand the DDJ-SR's MIDI protocol, then proceed to Step 2: building the synth engine and mapping MIDI input to sound generation.
