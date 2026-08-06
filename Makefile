.PHONY: build clean run install help

# Default target
help:
	@echo "KnobeatMIDI - Build without Xcode"
	@echo ""
	@echo "Available targets:"
	@echo "  make build    - Build the project using Swift Package Manager"
	@echo "  make run      - Build and run the application"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make install  - Install to /usr/local/bin (requires sudo)"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Swift toolchain (download from swift.org or install via Homebrew)"
	@echo "  - macOS 11.0 (Big Sur) or later"

# Build the project
build:
	@echo "🔨 Building KnobeatMIDI..."
	swift build -c release
	@echo "✅ Build complete: .build/release/KnobeatMIDI"

# Run the application
run: build
	@echo "🚀 Running KnobeatMIDI..."
	./.build/release/KnobeatMIDI

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "✅ Clean complete"

# Install to system
install: build
	@echo "📦 Installing KnobeatMIDI to /usr/local/bin..."
	sudo cp .build/release/KnobeatMIDI /usr/local/bin/
	@echo "✅ Installation complete"
	@echo "You can now run 'KnobeatMIDI' from anywhere"
