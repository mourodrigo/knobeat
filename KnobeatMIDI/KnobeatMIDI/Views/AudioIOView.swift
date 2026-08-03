//
//  AudioIOView.swift
//  KnobeatMIDI
//
//  Audio I/O testing panel for DDJ-SR audio interface
//

import SwiftUI

struct AudioIOView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Audio I/O Testing")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                if audioManager.ddjSRAudioDetected {
                    Label("DDJ-SR Audio Detected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                
                Button(action: {
                    audioManager.refreshDevices()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            Divider()
            
            // Input Device Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Input Devices")
                    .font(.headline)
                
                if audioManager.inputDevices.isEmpty {
                    Text("No audio input devices found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(audioManager.inputDevices) { device in
                                AudioDeviceButton(
                                    device: device,
                                    isSelected: audioManager.selectedInputDevice == device.id,
                                    action: {
                                        audioManager.selectedInputDevice = device.id
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Output Device Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Output Devices")
                    .font(.headline)
                
                if audioManager.outputDevices.isEmpty {
                    Text("No audio output devices found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(audioManager.outputDevices) { device in
                                AudioDeviceButton(
                                    device: device,
                                    isSelected: audioManager.selectedOutputDevice == device.id,
                                    action: {
                                        audioManager.selectedOutputDevice = device.id
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Passthrough Controls
            VStack(alignment: .leading, spacing: 15) {
                Text("Audio Passthrough")
                    .font(.headline)
                
                Text("Route input to output to test the audio path from your DDJ-SR mixer channels")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    if audioManager.isPassthroughActive {
                        Button(action: {
                            audioManager.stopPassthrough()
                        }) {
                            Label("Stop Passthrough", systemImage: "stop.fill")
                                .frame(width: 200)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else {
                        Button(action: {
                            audioManager.startPassthrough()
                        }) {
                            Label("Start Passthrough", systemImage: "play.fill")
                                .frame(width: 200)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(audioManager.selectedInputDevice == nil || 
                                audioManager.selectedOutputDevice == nil)
                    }
                }
                
                if audioManager.isPassthroughActive {
                    VStack(spacing: 15) {
                        // Input Level Meter
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Input Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LevelMeter(level: audioManager.inputLevel, color: .green)
                        }
                        
                        // Output Level Meter
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Output Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LevelMeter(level: audioManager.outputLevel, color: .blue)
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.2))
            .cornerRadius(12)
            
            Spacer()
            
            // Info Box
            VStack(alignment: .leading, spacing: 10) {
                Label("Note", systemImage: "info.circle")
                    .font(.headline)
                
                Text("""
                Audio passthrough allows you to test the audio interface of your DDJ-SR controller. \
                Select an input device (preferably your DDJ-SR), select an output device, and click \
                "Start Passthrough" to route audio from input to output. You should hear audio from \
                your input source through the selected output device.
                
                This is a basic diagnostic tool. For production use, you would typically use a DAW or \
                DJ software that properly manages audio latency and buffering.
                """)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Audio Device Button
struct AudioDeviceButton: View {
    let device: AudioDeviceInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(device.name)
                        .font(.headline)
                        .lineLimit(2)
                    
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
                
                HStack {
                    if device.inputChannels > 0 {
                        Label("\(device.inputChannels) in", systemImage: "arrow.down")
                            .font(.caption2)
                    }
                    if device.outputChannels > 0 {
                        Label("\(device.outputChannels) out", systemImage: "arrow.up")
                            .font(.caption2)
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(minWidth: 220, maxWidth: 220)
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

// MARK: - Level Meter
struct LevelMeter: View {
    let level: Float
    let color: Color
    
    private var normalizedLevel: Double {
        // Convert linear amplitude to a more useful display scale
        let db = 20 * log10(max(level, 0.001))
        let normalizedDB = (db + 60) / 60 // Normalize -60dB to 0dB range to 0-1
        return min(max(Double(normalizedDB), 0.0), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                
                // Level bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.6), color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(normalizedLevel))
                
                // Peak indicators
                ForEach([0.5, 0.75, 0.9], id: \.self) { threshold in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1)
                        .offset(x: geometry.size.width * CGFloat(threshold))
                }
            }
        }
        .frame(height: 20)
    }
}

#Preview {
    AudioIOView()
        .environmentObject(AudioManager())
        .frame(width: 800, height: 600)
}
