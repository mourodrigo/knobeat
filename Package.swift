// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

// Set KNOBEAT_NO_TESTS=1 to exclude test targets on macOS CLT-only environments
// where `xctest` is unavailable (no full Xcode installed).
// Example: KNOBEAT_NO_TESTS=1 swift build -c release
let disableTests = ProcessInfo.processInfo.environment["KNOBEAT_NO_TESTS"] == "1"

var targets: [Target] = [
    .executableTarget(
        name: "KnobeatMIDI",
        path: "KnobeatMIDI/KnobeatMIDI",
        exclude: [
            "Info.plist",
            "Assets.xcassets"
        ],
        sources: [
            "KnobeatMIDIApp.swift",
            "ContentView.swift",
            "Views/MIDIInputView.swift",
            "Views/MIDIOutputView.swift",
            "Views/AudioIOView.swift",
            "Models/MIDIManager.swift",
            "Models/AudioManager.swift",
            "Models/DDJSRMappings.swift"
        ],
        linkerSettings: [
            .linkedFramework("CoreMIDI"),
            .linkedFramework("AVFoundation"),
            .linkedFramework("CoreAudio"),
            .linkedFramework("SwiftUI")
        ]
    )
]

let package = Package(
    name: "KnobeatMIDI",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "KnobeatMIDI",
            targets: ["KnobeatMIDI"]
        )
    ],
    targets: targets
)
