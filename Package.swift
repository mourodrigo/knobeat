// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KnobeatMIDI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "KnobeatMIDI",
            targets: ["KnobeatMIDI"]
        )
    ],
    targets: [
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
)
