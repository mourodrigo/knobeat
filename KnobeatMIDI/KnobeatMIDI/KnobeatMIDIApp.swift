//
//  KnobeatMIDIApp.swift
//  KnobeatMIDI
//
//  macOS MIDI Detection App for Pioneer DDJ-SR
//

import SwiftUI

@main
struct KnobeatMIDIApp: App {
    @StateObject private var midiManager = MIDIManager()
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(midiManager)
                .environmentObject(audioManager)
                .frame(minWidth: 900, minHeight: 700)
        }
    }
}
