//
//  MIDIInputView.swift
//  KnobeatMIDI
//
//  MIDI input panel with device selection and message logging
//

import SwiftUI

struct MIDIInputView: View {
    @EnvironmentObject var midiManager: MIDIManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("MIDI Input Monitor")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                if midiManager.ddjSRDetected {
                    Label("DDJ-SR Detected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                
                Button(action: {
                    midiManager.refreshDevices()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            Divider()
            
            // Device Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("MIDI Sources")
                    .font(.headline)
                
                if midiManager.sources.isEmpty {
                    Text("No MIDI devices found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(midiManager.sources) { source in
                                DeviceButton(
                                    device: source,
                                    isSelected: midiManager.selectedSourceIndex == source.id,
                                    action: {
                                        midiManager.connectToSource(source.id)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Message Log
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Message Log")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(midiManager.messages.count) messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        midiManager.clearMessages()
                    }) {
                        Label("Clear", systemImage: "trash")
                            .font(.caption)
                    }
                }
                
                if midiManager.messages.isEmpty {
                    Text("No messages received. Play notes or move controls on your MIDI device.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(midiManager.messages) { message in
                                MessageRow(message: message)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Device Button
struct DeviceButton: View {
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

// MARK: - Message Row
struct MessageRow: View {
    let message: MIDIMessage
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp
            Text(timeString)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            
            // Raw hex
            Text(message.rawHex)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.blue)
                .frame(width: 80, alignment: .leading)
            
            // Decoded message
            Text(message.decoded)
                .font(.system(.caption, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}

#Preview {
    MIDIInputView()
        .environmentObject(MIDIManager())
        .frame(width: 800, height: 600)
}
