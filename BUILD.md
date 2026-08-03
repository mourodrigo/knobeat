# Building KnobeatMIDI Without Xcode

This guide explains how to build and run KnobeatMIDI on macOS without installing Xcode.

## Prerequisites

### Install Swift Toolchain

You need the Swift compiler, which can be installed without Xcode:

**Option 1: Homebrew (Recommended)**
```bash
brew install swift
```

**Option 2: Official Swift Toolchain**
1. Visit [swift.org/download](https://www.swift.org/download/)
2. Download the Swift toolchain for macOS
3. Install the .pkg file
4. Verify installation:
   ```bash
   swift --version
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
