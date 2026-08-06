//
//  MIDIOutputView.swift
//  KnobeatMIDI
//
//  MIDI output panel with test controls for DDJ-SR LEDs and hardware
//

import SwiftUI

struct MIDIOutputView: View {
    @EnvironmentObject var midiManager: MIDIManager
    @State private var selectedChannel: UInt8 = 0
    @State private var manualStatusByte: String = "90"
    @State private var manualData1: String = "60"
    @State private var manualData2: String = "127"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("MIDI Output Testing")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    midiManager.refreshDevices()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            Divider()
            
            // Destination Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("MIDI Destinations")
                    .font(.headline)
                
                if midiManager.destinations.isEmpty {
                    Text("No MIDI destinations found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(midiManager.destinations) { dest in
                                DestinationButton(
                                    device: dest,
                                    isSelected: midiManager.selectedDestinationIndex == dest.id,
                                    action: {
                                        midiManager.selectedDestinationIndex = dest.id
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // DDJ-SR Test Patterns
                    if let destIndex = midiManager.selectedDestinationIndex,
                       destIndex < midiManager.destinations.count,
                       midiManager.destinations[destIndex].isDDJSR {
                        DDJSRTestSection(destinationIndex: destIndex)
                    }
                    
                    // Manual Message Sender
                    ManualMessageSection(
                        selectedChannel: $selectedChannel,
                        statusByte: $manualStatusByte,
                        data1: $manualData1,
                        data2: $manualData2
                    )
                }
                .padding(.vertical)
            }
        }
        .padding()
    }
}

// MARK: - Destination Button
struct DestinationButton: View {
    let device: MIDIDeviceInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if device.isDDJSR {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                if !device.manufacturer.isEmpty {
                    Text(device.manufacturer)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(minWidth: 200)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DDJ-SR Test Section
struct DDJSRTestSection: View {
    @EnvironmentObject var midiManager: MIDIManager
    let destinationIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("DDJ-SR LED Test Patterns")
                .font(.headline)
            
            Text("Test the DDJ-SR's pad LEDs, transport buttons, and other hardware feedback")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Test Pattern Buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(DDJSRMappings.TestPattern.allPatterns, id: \.name) { pattern in
                    Button(action: {
                        executeTestPattern(pattern)
                    }) {
                        Text(pattern.name)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
            Divider()
            
            // Individual Pad Controls
            VStack(alignment: .leading, spacing: 10) {
                Text("Deck A Pads")
                    .font(.subheadline)
                    .bold()
                
                HStack(spacing: 8) {
                    ForEach(0..<8) { index in
                        PadButton(
                            label: "\(index + 1)",
                            action: {
                                let pads = DDJSRMappings.getAllDeckAPads()
                                if index < pads.count {
                                    sendPadMessage(pads[index], ledState: .red)
                                }
                            }
                        )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Deck B Pads")
                    .font(.subheadline)
                    .bold()
                
                HStack(spacing: 8) {
                    ForEach(0..<8) { index in
                        PadButton(
                            label: "\(index + 1)",
                            action: {
                                let pads = DDJSRMappings.getAllDeckBPads()
                                if index < pads.count {
                                    sendPadMessage(pads[index], ledState: .blue)
                                }
                            }
                        )
                    }
                }
            }
            
            // Transport Controls
            VStack(alignment: .leading, spacing: 10) {
                Text("Transport Buttons")
                    .font(.subheadline)
                    .bold()
                
                HStack(spacing: 10) {
                    Button("Deck A Play") {
                        sendControlMessage(DDJSRMappings.DeckATransport.play, value: 0x7F)
                    }
                    
                    Button("Deck A Cue") {
                        sendControlMessage(DDJSRMappings.DeckATransport.cue, value: 0x7F)
                    }
                    
                    Button("Deck B Play") {
                        sendControlMessage(DDJSRMappings.DeckBTransport.play, value: 0x7F)
                    }
                    
                    Button("Deck B Cue") {
                        sendControlMessage(DDJSRMappings.DeckBTransport.cue, value: 0x7F)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(12)
    }
    
    private func executeTestPattern(_ pattern: DDJSRMappings.TestPattern) {
        for control in pattern.controls {
            sendPadMessage(control, ledState: pattern.ledState)
        }
    }
    
    private func sendPadMessage(_ control: DDJSRMappings.MIDIControl, ledState: DDJSRMappings.LEDState) {
        if let note = control.note {
            midiManager.sendMessage(
                destination: destinationIndex,
                statusByte: 0x90 | control.channel,
                data1: note,
                data2: ledState.rawValue
            )
        }
    }
    
    private func sendControlMessage(_ control: DDJSRMappings.MIDIControl, value: UInt8) {
        if let note = control.note {
            midiManager.sendMessage(
                destination: destinationIndex,
                statusByte: 0x90 | control.channel,
                data1: note,
                data2: value
            )
        } else if let cc = control.cc {
            midiManager.sendMessage(
                destination: destinationIndex,
                statusByte: 0xB0 | control.channel,
                data1: cc,
                data2: value
            )
        }
    }
}

// MARK: - Pad Button
struct PadButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Manual Message Section
struct ManualMessageSection: View {
    @EnvironmentObject var midiManager: MIDIManager
    @Binding var selectedChannel: UInt8
    @Binding var statusByte: String
    @Binding var data1: String
    @Binding var data2: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Manual Message Sender")
                .font(.headline)
            
            Text("Send custom MIDI messages with manual control")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Channel:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $selectedChannel) {
                        ForEach(0..<16) { ch in
                            Text("\(ch + 1)").tag(UInt8(ch))
                        }
                    }
                    .frame(width: 100)
                }
                
                HStack {
                    Text("Status (hex):")
                        .frame(width: 80, alignment: .leading)
                    TextField("90", text: $statusByte)
                        .frame(width: 100)
                        .textFieldStyle(.roundedBorder)
                    Text("(e.g., 90=Note On, B0=CC)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Data 1 (hex):")
                        .frame(width: 80, alignment: .leading)
                    TextField("60", text: $data1)
                        .frame(width: 100)
                        .textFieldStyle(.roundedBorder)
                    Text("(note/CC number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Data 2 (hex):")
                        .frame(width: 80, alignment: .leading)
                    TextField("7F", text: $data2)
                        .frame(width: 100)
                        .textFieldStyle(.roundedBorder)
                    Text("(velocity/value)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: sendManualMessage) {
                    Label("Send Message", systemImage: "paperplane.fill")
                        .frame(maxWidth: 200)
                }
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                .disabled(midiManager.selectedDestinationIndex == nil)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(12)
    }
    
    private func sendManualMessage() {
        guard let destIndex = midiManager.selectedDestinationIndex else { return }
        
        guard let status = UInt8(statusByte, radix: 16),
              let d1 = UInt8(data1, radix: 16),
              let d2 = UInt8(data2, radix: 16) else {
            print("Invalid hex values")
            return
        }
        
        midiManager.sendMessage(
            destination: destIndex,
            statusByte: status,
            data1: d1,
            data2: d2
        )
    }
}

struct MIDIOutputView_Previews: PreviewProvider {
    static var previews: some View {
        MIDIOutputView()
            .environmentObject(MIDIManager())
            .frame(width: 800, height: 600)
    }
}
