# Building KnobeatMIDI Without Xcode

This guide explains how to build and run KnobeatMIDI on macOS without installing the full Xcode IDE.

## Important: Command Line Tools Required

While you don't need the full Xcode IDE (~12+ GB), Swift Package Manager on macOS requires **Xcode Command Line Tools** (~1-2 GB). This includes:
- Swift compiler
- Build tools (xcrun, xcodebuild utilities)
- macOS SDK headers
- Linker and other essential tools

**This is not the same as full Xcode** - it's much smaller and installs quickly.

## Prerequisites

### Install Xcode Command Line Tools

**Option 1: Using xcode-select (Recommended)**
```bash
xcode-select --install
```

This will open a dialog to download and install Command Line Tools.

**Option 2: Download from Apple**
1. Visit [developer.apple.com/downloads](https://developer.apple.com/downloads)
2. Sign in with your Apple ID (free account works)
3. Search for "Command Line Tools for Xcode"
4. Download the version matching your macOS

**Verify Installation:**
```bash
xcode-select -p
# Should output: /Library/Developer/CommandLineTools

swift --version
# Should show Swift version
```

### System Requirements
- macOS 13.0 (Ventura) or later
- Swift 5.9 or later

## Building the Project

### Quick Build

The simplest way to build is using the provided build script:

```bash
./build.sh
```

This will:
1. Check if Swift is installed
2. Build the project in release mode
3. Show the location of the executable

### Using Make

We provide a Makefile for convenient building:

```bash
# Build the project
make build

# Build and run
make run

# Clean build artifacts
make clean

# Install system-wide (requires sudo)
make install
```

### Manual Build with Swift Package Manager

If you prefer to use Swift Package Manager directly:

```bash
# Debug build
swift build

# Release build (optimized)
swift build -c release

# Run the executable
./.build/release/KnobeatMIDI
```

## Running the Application

After building, you can run the app:

```bash
# From the build directory
./.build/release/KnobeatMIDI

# Or if installed system-wide
KnobeatMIDI
```

The SwiftUI interface will launch just like a regular macOS app.

## Understanding the Build Output

When built via command line (Swift Package Manager), you get:
- A native executable at `.build/release/KnobeatMIDI`
- Direct access to the same CoreMIDI, AVFoundation, and SwiftUI frameworks
- Full functionality without Xcode

The only difference from Xcode builds:
- No .app bundle (just a binary executable)
- No Info.plist embedded (uses defaults)
- No app icon in Dock (uses generic icon)

The MIDI, audio, and UI functionality are identical.

## Troubleshooting

### Error: "xcrun: error: unable to find utility 'xctest'" with Old Swift Version

**Problem:**
```
Swift version 5.4.2 (or older)
error: terminated(72): /usr/bin/xcrun --sdk macosx --find xctest output:
    xcrun: error: unable to find utility "xctest", not a developer tool or in PATH
```

**Cause:** Your Swift version is too old. This project requires Swift 5.9+, which comes with macOS 13 (Ventura) or later Command Line Tools.

**Check your versions:**
```bash
swift --version
# You need: Swift 5.9 or later
# If you see: Swift 5.4.x, 5.5.x, etc. - too old

sw_vers
# Check your macOS version
```

**Solution - Choose based on your macOS version:**

**If you're on macOS 13 (Ventura) or later:**
```bash
# Update Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

**If you're on macOS 12 (Monterey) or earlier:**

You have three options:

1. **Upgrade macOS (Recommended)**
   - Upgrade to macOS 13 (Ventura) or later
   - Then install latest Command Line Tools: `xcode-select --install`

2. **Install full Xcode**
   - Download Xcode 15+ from Mac App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - This gives you the latest Swift even on older macOS

3. **Try lowering Swift version requirement** (Advanced)
   - Edit `Package.swift` and change `// swift-tools-version: 5.9` to match your Swift version
   - Note: This may cause compilation errors if the code uses newer Swift features

**Swift Version by macOS:**
- macOS 14 (Sonoma): Swift 5.9+
- macOS 13 (Ventura): Swift 5.7-5.9
- macOS 12 (Monterey): Swift 5.5-5.7
- macOS 11 (Big Sur): Swift 5.3-5.5
- macOS 10.15 (Catalina): Swift 5.1-5.3

### Error: "xcrun: error: unable to find utility 'xctest'" with Command Line Tools Missing

**Problem:**
```
error: terminated(72): /usr/bin/xcrun --sdk macosx --find xctest output:
    xcrun: error: unable to find utility "xctest", not a developer tool or in PATH
```

**Cause:** Xcode Command Line Tools are not installed properly, or you're using an older Swift version (5.5.x) that has issues with xctest on some systems.

**Solution:**

**Option 1: Use the build script or Makefile (Recommended)**
```bash
# Using build script
./build.sh

# Or using make
make build
```

**Option 2: Install/Reinstall Command Line Tools**
```bash
# Install Command Line Tools
xcode-select --install

# After installation, verify
xcode-select -p
# Should show: /Library/Developer/CommandLineTools

# Then rebuild
./build.sh
```

**Option 3: Upgrade to newer Swift/macOS**
The xctest error is common on older Swift versions (5.5.x and earlier). Consider:
- Upgrading to macOS 13+ (includes Swift 5.9+)
- Installing full Xcode for latest Swift version

If you already have Command Line Tools but still get this error:
```bash
# Reset the tools path
sudo xcode-select --reset

# Or if you have Xcode installed, point to it
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Swift Not Found

If you get "swift: command not found":
1. Install Swift via Homebrew: `brew install swift`
2. Or download from [swift.org](https://www.swift.org/download/)
3. Ensure Swift is in your PATH

### Build Errors

**Missing frameworks:**
- Ensure you're on macOS 13.0 or later
- CoreMIDI, AVFoundation, and SwiftUI are system frameworks and should be available

**Permission errors:**
- Make sure the build script is executable: `chmod +x build.sh`

### Runtime Issues

**"Cannot open because the developer cannot be verified":**
- This happens when running unsigned executables
- Right-click the executable and select "Open"
- Or run from Terminal (already trusted)

**Audio/MIDI permissions:**
- macOS will prompt for microphone/audio access on first run
- Grant permissions in System Settings > Privacy & Security

## Comparison with Xcode Build

| Feature | Command Line Build | Xcode Build |
|---------|-------------------|-------------|
| Requires Xcode | ❌ No | ✅ Yes |
| Build time | Faster (SPM) | Slower (full IDE) |
| Output format | Executable | .app bundle |
| App icon | Generic | Custom |
| Info.plist | Default | Custom |
| Functionality | Full | Full |
| Code signing | Manual | Automatic |
| Debugging | lldb CLI | Xcode debugger |

## Advanced Usage

### Custom Build Configurations

```bash
# Build for specific architecture
swift build -c release --arch arm64

# Build with debug symbols
swift build -c release -Xswiftc -g

# Verbose output
swift build -c release -v
```

### Development Workflow

```bash
# Quick iteration during development
swift build && ./.build/debug/KnobeatMIDI

# Watch for file changes (requires fswatch)
fswatch -o KnobeatMIDI/KnobeatMIDI | xargs -n1 -I{} swift build
```

### Code Signing (Optional)

If you want to sign the executable:

```bash
# Sign with ad-hoc signature
codesign --force --deep --sign - .build/release/KnobeatMIDI

# Or with your Developer ID
codesign --force --deep --sign "Developer ID Application: Your Name" .build/release/KnobeatMIDI
```

## IDE Alternatives

If you want an IDE experience without Xcode:

1. **VS Code + Swift Extension**
   - Install [Swift extension](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)
   - Open the project folder
   - Use integrated terminal for builds

2. **AppCode (JetBrains)**
   - Commercial IDE for Swift
   - Supports Swift Package Manager
   - Full debugging and refactoring

3. **Vim/Neovim + SourceKit-LSP**
   - Lightweight option
   - Swift language server support
   - Terminal-based workflow

## Benefits of Command Line Builds

✅ **No Xcode download** (12+ GB saved)  
✅ **Faster build times** (SPM is lightweight)  
✅ **CI/CD friendly** (easy to automate)  
✅ **Version control friendly** (no .xcodeproj bloat)  
✅ **Cross-platform development** (SPM works on Linux too)  
✅ **Modern Swift workflow** (SPM is the standard)  

## Next Steps

Once you have the app built and running:
1. Connect your Pioneer DDJ-SR or other MIDI controller
2. Follow the usage guide in the main README.md
3. Explore MIDI input monitoring, output testing, and audio I/O

For more information, see the main [README.md](README.md) file.
