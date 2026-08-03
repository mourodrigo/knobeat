#!/bin/bash
# Build script for KnobeatMIDI without Xcode
# Requires: Swift toolchain installed (download from swift.org)

set -e

echo "🔨 Building KnobeatMIDI using Swift Package Manager..."
echo ""

# Check if swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift compiler not found!"
    echo ""
    echo "To build without Xcode, you need to install the Swift toolchain:"
    echo "1. Download from: https://www.swift.org/download/"
    echo "2. Or install via Homebrew: brew install swift"
    echo ""
    exit 1
fi

# Display Swift version
echo "Swift version:"
swift --version
echo ""

# Build the project
echo "Building..."
swift build -c release

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
