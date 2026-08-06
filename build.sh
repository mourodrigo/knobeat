#!/bin/bash
# Build script for KnobeatMIDI without Xcode
# Requires: Xcode Command Line Tools (not full Xcode)

set -e

echo "🔨 Building KnobeatMIDI using Swift Package Manager..."
echo ""

# Check if swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift compiler not found!"
    echo ""
    echo "To build without Xcode, you need to install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    echo ""
    echo "Alternative: Install via Homebrew: brew install swift"
    echo ""
    exit 1
fi

# Check if Command Line Tools are installed
if ! xcode-select -p &> /dev/null; then
    echo "❌ Error: Xcode Command Line Tools not found!"
    echo ""
    echo "Swift Package Manager requires Apple's Command Line Tools to build on macOS."
    echo "This is much smaller than full Xcode (~1-2 GB vs 12+ GB)."
    echo ""
    echo "To install Command Line Tools:"
    echo "  xcode-select --install"
    echo ""
    echo "After installation, run this script again."
    echo ""
    exit 1
fi

# Display Swift version
echo "Swift version:"
swift --version
echo ""

# Check Swift version (need 5.9+)
SWIFT_VERSION=$(swift --version | head -n 1 | sed -n 's/.*Swift version \([0-9]*\.[0-9]*\).*/\1/p')
SWIFT_MAJOR=$(echo $SWIFT_VERSION | cut -d. -f1)
SWIFT_MINOR=$(echo $SWIFT_VERSION | cut -d. -f2)

if [ "$SWIFT_MAJOR" -lt 5 ] || ([ "$SWIFT_MAJOR" -eq 5 ] && [ "$SWIFT_MINOR" -lt 5 ]); then
    echo "❌ Error: Swift version $SWIFT_VERSION is too old!"
    echo ""
    echo "This project requires Swift 5.5 or later, but you have Swift $SWIFT_VERSION."
    echo ""
    echo "Your Command Line Tools are from an older macOS version."
    echo "To update to a newer Swift version, you need to:"
    echo ""
    echo "Option 1: Update your macOS to the latest version"
    echo "  - This will also update Command Line Tools and Swift"
    echo ""
    echo "Option 2: Update Command Line Tools"
    echo "  1. Check your macOS version: sw_vers"
    echo "  2. Download matching Command Line Tools from:"
    echo "     https://developer.apple.com/download/all/"
    echo "  3. Install the latest version for your macOS"
    echo ""
    echo "Option 3: Install Xcode (includes latest Swift)"
    echo "  - Download from Mac App Store"
    echo "  - Then run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo ""
    echo "Swift version requirements:"
    echo "  - macOS 11 (Big Sur): Swift 5.5+"
    echo "  - macOS 12 (Monterey): Swift 5.7+"
    echo "  - macOS 13 (Ventura): Swift 5.9+"
    echo ""
    exit 1
fi

echo "✅ Swift version check passed (requires 5.5+)"
echo ""

# Build the project
echo "Building..."
swift build -c release --disable-sandbox

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "The executable is located at:"
    echo "  .build/release/KnobeatMIDI"
    echo ""
    echo "To run the app:"
    echo "  ./.build/release/KnobeatMIDI"
    echo ""
    echo "Note: The app runs as a command-line executable since it's built"
    echo "      without Xcode's app bundle creation. For a full .app bundle,"
    echo "      use the create_app_bundle.sh script."
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
