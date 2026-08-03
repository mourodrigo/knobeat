# Quick Start - Building Without Xcode

## Prerequisites
```bash
# Install Xcode Command Line Tools (NOT full Xcode)
xcode-select --install

# Verify installation
xcode-select -p
swift --version
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
- Xcode Command Line Tools (install with: `xcode-select --install`)
- **No full Xcode installation required!** (saves ~10 GB)

## Common Issues

### Error: "xcrun: error: unable to find utility 'xctest'"
You need Command Line Tools:
```bash
xcode-select --install
```

## Full Documentation

See [BUILD.md](BUILD.md) for comprehensive build instructions and troubleshooting.
