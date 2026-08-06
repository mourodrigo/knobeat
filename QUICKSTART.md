# Quick Start - Building Without Xcode

## Prerequisites
```bash
# Install Xcode Command Line Tools (NOT full Xcode)
xcode-select --install

# Verify installation and Swift version
xcode-select -p
swift --version
# You need Swift 5.9 or later
```

**Important:** If you see Swift 5.4.x or older, your Command Line Tools are outdated.
See troubleshooting below.

## Build Commands

```bash
# Quick build
./build.sh

# Or with make
make build

# Manual SPM build
swift build -c release --disable-xctest
```

## Run

```bash
# Run the executable
./.build/release/KnobeatMIDI

# Or install system-wide
make install
KnobeatMIDI
```

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode Command Line Tools with Swift 5.9+ (install with: `xcode-select --install`)
- **No full Xcode installation required!** (saves ~10 GB)

## Common Issues

### Error: "xcrun: error: unable to find utility 'xctest'"

**If you have Swift 5.4.x or older:**
Your Command Line Tools are too old. You need Swift 5.9+.

```bash
# Check your versions
swift --version
sw_vers

# Solution 1: Update macOS to 13+ and reinstall Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install

# Solution 2: Install full Xcode (works on older macOS)
# Download from Mac App Store, then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**If Command Line Tools are not installed:**
```bash
xcode-select --install
```

## Full Documentation

See [BUILD.md](BUILD.md) for comprehensive build instructions and troubleshooting.
