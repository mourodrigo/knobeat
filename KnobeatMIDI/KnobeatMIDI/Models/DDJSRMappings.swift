//
//  DDJSRMappings.swift
//  KnobeatMIDI
//
//  Pioneer DDJ-SR MIDI mappings (community-documented)
//  Based on Mixxx and other open-source controller mappings
//

import Foundation

// MARK: - DDJ-SR Control Mappings
struct DDJSRMappings {
    
    // MARK: - Performance Pads (Deck A/Left)
    struct DeckAPerformancePads {
        static let pad1 = MIDIControl(channel: 0, note: 0x1B, type: .note)
        static let pad2 = MIDIControl(channel: 0, note: 0x1C, type: .note)
        static let pad3 = MIDIControl(channel: 0, note: 0x1D, type: .note)
        static let pad4 = MIDIControl(channel: 0, note: 0x1E, type: .note)
        static let pad5 = MIDIControl(channel: 0, note: 0x1F, type: .note)
        static let pad6 = MIDIControl(channel: 0, note: 0x20, type: .note)
        static let pad7 = MIDIControl(channel: 0, note: 0x21, type: .note)
        static let pad8 = MIDIControl(channel: 0, note: 0x22, type: .note)
    }
    
    // MARK: - Performance Pads (Deck B/Right)
    struct DeckBPerformancePads {
        static let pad1 = MIDIControl(channel: 1, note: 0x1B, type: .note)
        static let pad2 = MIDIControl(channel: 1, note: 0x1C, type: .note)
        static let pad3 = MIDIControl(channel: 1, note: 0x1D, type: .note)
        static let pad4 = MIDIControl(channel: 1, note: 0x1E, type: .note)
        static let pad5 = MIDIControl(channel: 1, note: 0x1F, type: .note)
        static let pad6 = MIDIControl(channel: 1, note: 0x20, type: .note)
        static let pad7 = MIDIControl(channel: 1, note: 0x21, type: .note)
        static let pad8 = MIDIControl(channel: 1, note: 0x22, type: .note)
    }
    
    // MARK: - Transport Controls (Deck A)
    struct DeckATransport {
        static let play = MIDIControl(channel: 0, note: 0x0B, type: .note)
        static let cue = MIDIControl(channel: 0, note: 0x0C, type: .note)
        static let sync = MIDIControl(channel: 0, note: 0x58, type: .note)
    }
    
    // MARK: - Transport Controls (Deck B)
    struct DeckBTransport {
        static let play = MIDIControl(channel: 1, note: 0x0B, type: .note)
        static let cue = MIDIControl(channel: 1, note: 0x0C, type: .note)
        static let sync = MIDIControl(channel: 1, note: 0x58, type: .note)
    }
    
    // MARK: - VU Meters / Level Indicators
    // These are typically CC messages sent TO the controller
    struct VUMeters {
        // VU meter LEDs are controlled via CC messages
        // Note: These are approximate based on community mappings
        static let deckALevel = MIDIControl(channel: 0, cc: 0x02, type: .cc)
        static let deckBLevel = MIDIControl(channel: 1, cc: 0x02, type: .cc)
    }
    
    // MARK: - Loop Controls
    struct DeckALoop {
        static let loopIn = MIDIControl(channel: 0, note: 0x10, type: .note)
        static let loopOut = MIDIControl(channel: 0, note: 0x11, type: .note)
        static let reloop = MIDIControl(channel: 0, note: 0x4D, type: .note)
    }
    
    struct DeckBLoop {
        static let loopIn = MIDIControl(channel: 1, note: 0x10, type: .note)
        static let loopOut = MIDIControl(channel: 1, note: 0x11, type: .note)
        static let reloop = MIDIControl(channel: 1, note: 0x4D, type: .note)
    }
    
    // MARK: - LED Colors
    // LED brightness/color values for pad feedback
    enum LEDState: UInt8 {
        case off = 0x00
        case dimRed = 0x01
        case red = 0x02
        case dimGreen = 0x1A
        case green = 0x1B
        case dimBlue = 0x34
        case blue = 0x35
        case dimYellow = 0x36
        case yellow = 0x37
        case dimOrange = 0x0E
        case orange = 0x0F
        case brightRed = 0x7F
    }
    
    // MARK: - Helper Types
    enum ControlType {
        case note
        case cc
    }
    
    struct MIDIControl {
        let channel: UInt8
        let note: UInt8?
        let cc: UInt8?
        let type: ControlType
        
        init(channel: UInt8, note: UInt8, type: ControlType) {
            self.channel = channel
            self.note = note
            self.cc = nil
            self.type = type
        }
        
        init(channel: UInt8, cc: UInt8, type: ControlType) {
            self.channel = channel
            self.note = nil
            self.cc = cc
            self.type = type
        }
        
        var description: String {
            switch type {
            case .note:
                return "Ch\(channel + 1) Note \(note!)"
            case .cc:
                return "Ch\(channel + 1) CC \(cc!)"
            }
        }
    }
    
    // MARK: - Test Sequences
    // Pre-defined test sequences for easy LED testing
    static func getAllDeckAPads() -> [MIDIControl] {
        return [
            DeckAPerformancePads.pad1,
            DeckAPerformancePads.pad2,
            DeckAPerformancePads.pad3,
            DeckAPerformancePads.pad4,
            DeckAPerformancePads.pad5,
            DeckAPerformancePads.pad6,
            DeckAPerformancePads.pad7,
            DeckAPerformancePads.pad8
        ]
    }
    
    static func getAllDeckBPads() -> [MIDIControl] {
        return [
            DeckBPerformancePads.pad1,
            DeckBPerformancePads.pad2,
            DeckBPerformancePads.pad3,
            DeckBPerformancePads.pad4,
            DeckBPerformancePads.pad5,
            DeckBPerformancePads.pad6,
            DeckBPerformancePads.pad7,
            DeckBPerformancePads.pad8
        ]
    }
    
    static func getAllTransportButtons() -> [MIDIControl] {
        return [
            DeckATransport.play,
            DeckATransport.cue,
            DeckATransport.sync,
            DeckBTransport.play,
            DeckBTransport.cue,
            DeckBTransport.sync
        ]
    }
}

// MARK: - Test Patterns
extension DDJSRMappings {
    
    struct TestPattern {
        let name: String
        let controls: [MIDIControl]
        let ledState: LEDState
        
        static let allPadsRed = TestPattern(
            name: "All Pads Red",
            controls: getAllDeckAPads() + getAllDeckBPads(),
            ledState: .red
        )
        
        static let allPadsGreen = TestPattern(
            name: "All Pads Green",
            controls: getAllDeckAPads() + getAllDeckBPads(),
            ledState: .green
        )
        
        static let allPadsBlue = TestPattern(
            name: "All Pads Blue",
            controls: getAllDeckAPads() + getAllDeckBPads(),
            ledState: .blue
        )
        
        static let deckAPadsOrange = TestPattern(
            name: "Deck A Pads Orange",
            controls: getAllDeckAPads(),
            ledState: .orange
        )
        
        static let deckBPadsOrange = TestPattern(
            name: "Deck B Pads Orange",
            controls: getAllDeckBPads(),
            ledState: .orange
        )
        
        static let transportButtonsOn = TestPattern(
            name: "Transport Buttons On",
            controls: getAllTransportButtons(),
            ledState: .brightRed
        )
        
        static let allOff = TestPattern(
            name: "All Off",
            controls: getAllDeckAPads() + getAllDeckBPads() + getAllTransportButtons(),
            ledState: .off
        )
        
        static var allPatterns: [TestPattern] {
            return [
                allPadsRed,
                allPadsGreen,
                allPadsBlue,
                deckAPadsOrange,
                deckBPadsOrange,
                transportButtonsOn,
                allOff
            ]
        }
    }
}
