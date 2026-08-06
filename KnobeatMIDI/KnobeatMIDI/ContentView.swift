//
//  ContentView.swift
//  KnobeatMIDI
//
//  Main view with tabbed interface
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var midiManager: MIDIManager
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        TabView {
            MIDIInputView()
                .tabItem {
                    Label("MIDI Input", systemImage: "arrow.down.circle")
                }
            
            MIDIOutputView()
                .tabItem {
                    Label("MIDI Output", systemImage: "arrow.up.circle")
                }
            
            AudioIOView()
                .tabItem {
                    Label("Audio I/O", systemImage: "waveform")
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MIDIManager())
            .environmentObject(AudioManager())
    }
}
