# Quick Start - Building Without Xcode

## Prerequisites
```bash
# Install Swift via Homebrew
brew install swift

# Or download from swift.org
# https://www.swift.org/download/
```

## Build Commands

```bash
# Quick build
./build.sh

# Or with make
make build

# Manual SPM build
swift build -c release
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
- Swift 5.9+ (comes with Xcode Command Line Tools or standalone Swift toolchain)
- No Xcode installation required!

## Full Documentation

See [BUILD.md](BUILD.md) for comprehensive build instructions and troubleshooting.
