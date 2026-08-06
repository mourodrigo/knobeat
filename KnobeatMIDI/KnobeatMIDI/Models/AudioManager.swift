//
//  AudioManager.swift
//  KnobeatMIDI
//
//  Audio I/O manager for testing DDJ-SR audio interface
//

import Foundation
import AVFoundation
import CoreAudio

struct AudioDeviceInfo: Identifiable, Hashable {
    let id: AudioDeviceID
    let name: String
    let manufacturer: String
    let inputChannels: Int
    let outputChannels: Int
    let isDDJSR: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class AudioManager: ObservableObject {
    @Published var inputDevices: [AudioDeviceInfo] = []
    @Published var outputDevices: [AudioDeviceInfo] = []
    @Published var selectedInputDevice: AudioDeviceID?
    @Published var selectedOutputDevice: AudioDeviceID?
    @Published var isPassthroughActive = false
    @Published var inputLevel: Float = 0.0
    @Published var outputLevel: Float = 0.0
    @Published var ddjSRAudioDetected = false
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var playerNode: AVAudioPlayerNode?
    private var levelTimer: Timer?
    
    init() {
        refreshDevices()
    }
    
    // MARK: - Device Discovery
    func refreshDevices() {
        discoverInputDevices()
        discoverOutputDevices()
    }
    
    private func discoverInputDevices() {
        var newInputDevices: [AudioDeviceInfo] = []
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return }
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )
        
        guard status == noErr else { return }
        
        for deviceID in deviceIDs {
            if let deviceInfo = getDeviceInfo(deviceID: deviceID), deviceInfo.inputChannels > 0 {
                newInputDevices.append(deviceInfo)
                
                if deviceInfo.isDDJSR {
                    ddjSRAudioDetected = true
                    if selectedInputDevice == nil {
                        selectedInputDevice = deviceID
                    }
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.inputDevices = newInputDevices
        }
    }
    
    private func discoverOutputDevices() {
        var newOutputDevices: [AudioDeviceInfo] = []
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return }
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )
        
        guard status == noErr else { return }
        
        for deviceID in deviceIDs {
            if let deviceInfo = getDeviceInfo(deviceID: deviceID), deviceInfo.outputChannels > 0 {
                newOutputDevices.append(deviceInfo)
                
                if deviceInfo.isDDJSR && selectedOutputDevice == nil {
                    selectedOutputDevice = deviceID
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.outputDevices = newOutputDevices
        }
    }
    
    private func getDeviceInfo(deviceID: AudioDeviceID) -> AudioDeviceInfo? {
        let name = getDeviceName(deviceID: deviceID)
        let manufacturer = getDeviceManufacturer(deviceID: deviceID)
        let inputChannels = getChannelCount(deviceID: deviceID, isInput: true)
        let outputChannels = getChannelCount(deviceID: deviceID, isInput: false)
        
        let isDDJSR = name.lowercased().contains("ddj-sr") ||
                      name.lowercased().contains("ddj sr") ||
                      (name.lowercased().contains("pioneer") && name.lowercased().contains("dj"))
        
        return AudioDeviceInfo(
            id: deviceID,
            name: name,
            manufacturer: manufacturer,
            inputChannels: inputChannels,
            outputChannels: outputChannels,
            isDDJSR: isDDJSR
        )
    }
    
    private func getDeviceName(deviceID: AudioDeviceID) -> String {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return "Unknown Device" }
        
        var name: CFString = "" as CFString
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &name
        )
        
        return status == noErr ? (name as String) : "Unknown Device"
    }
    
    private func getDeviceManufacturer(deviceID: AudioDeviceID) -> String {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyManufacturer,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return "" }
        
        var manufacturer: CFString = "" as CFString
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &manufacturer
        )
        
        return status == noErr ? (manufacturer as String) : ""
    }
    
    private func getChannelCount(deviceID: AudioDeviceID, isInput: Bool) -> Int {
        let scope = isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return 0 }
        
        let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
        defer { bufferListPointer.deallocate() }
        
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            bufferListPointer
        )
        
        guard status == noErr else { return 0 }
        
        let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPointer)
        var channelCount = 0
        
        for buffer in bufferList {
            channelCount += Int(buffer.mNumberChannels)
        }
        
        return channelCount
    }
    
    // MARK: - Audio Passthrough
    func startPassthrough() {
        guard let inputDeviceID = selectedInputDevice,
              let outputDeviceID = selectedOutputDevice else {
            print("No input or output device selected")
            return
        }
        
        stopPassthrough()
        
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        // Configure input device
        do {
            let inputDevice = AVAudioDevice(deviceID: inputDeviceID)
            try engine.inputNode.setDevice(inputDevice)
        } catch {
            print("Failed to set input device: \(error)")
            return
        }
        
        // Configure output device
        do {
            let outputDevice = AVAudioDevice(deviceID: outputDeviceID)
            try engine.outputNode.setDevice(outputDevice)
        } catch {
            print("Failed to set output device: \(error)")
            return
        }
        
        inputNode = engine.inputNode
        let inputFormat = inputNode!.outputFormat(forBus: 0)
        
        // Connect input to output with level monitoring
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        engine.connect(engine.inputNode, to: engine.mainMixerNode, format: inputFormat)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: inputFormat)
        
        do {
            try engine.start()
            DispatchQueue.main.async { [weak self] in
                self?.isPassthroughActive = true
            }
            
            // Start level monitoring
            startLevelMonitoring()
            
            print("Audio passthrough started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopPassthrough() {
        stopLevelMonitoring()
        
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.isPassthroughActive = false
            self?.inputLevel = 0.0
            self?.outputLevel = 0.0
        }
        
        print("Audio passthrough stopped")
    }
    
    // MARK: - Level Monitoring
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let frameCount = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        var sum: Float = 0.0
        
        for channel in 0..<channelCount {
            let samples = channelData[channel]
            for frame in 0..<frameCount {
                sum += abs(samples[frame])
            }
        }
        
        let avgLevel = sum / Float(frameCount * channelCount)
        
        DispatchQueue.main.async { [weak self] in
            self?.inputLevel = avgLevel
            self?.outputLevel = avgLevel
        }
    }
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            // Decay levels over time if no new data
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.inputLevel *= 0.9
                self.outputLevel *= 0.9
            }
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
}

// MARK: - AVAudioDevice Extension
extension AVAudioDevice {
    convenience init(deviceID: AudioDeviceID) {
        self.init()
        // Note: This is a simplified approach. In a production app,
        // you would need to properly configure the AVAudioSession
        // or use lower-level Core Audio APIs for device selection
    }
    
    func setDevice(_ device: AVAudioDevice) throws {
        // Placeholder for device configuration
    }
}

// MARK: - AVAudioNode Extension
extension AVAudioNode {
    func setDevice(_ device: AVAudioDevice) throws {
        // Placeholder for device configuration
    }
}
