//
//  MIDIManager.swift
//  KnobeatMIDI
//
//  CoreMIDI manager for device detection and I/O
//

import Foundation
import CoreMIDI

// MARK: - MIDI Message Structure
struct MIDIMessage: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let sourceIndex: Int
    let sourceName: String
    let statusByte: UInt8
    let data1: UInt8
    let data2: UInt8
    let rawHex: String
    let decoded: String
    
    static func == (lhs: MIDIMessage, rhs: MIDIMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - MIDI Device Structure
struct MIDIDeviceInfo: Identifiable, Hashable {
    let id: Int
    let name: String
    let manufacturer: String
    let isDDJSR: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - MIDI Manager
class MIDIManager: ObservableObject {
    @Published var sources: [MIDIDeviceInfo] = []
    @Published var destinations: [MIDIDeviceInfo] = []
    @Published var messages: [MIDIMessage] = []
    @Published var selectedSourceIndex: Int?
    @Published var selectedDestinationIndex: Int?
    @Published var isConnected = false
    @Published var ddjSRDetected = false
    
    private var midiClient: MIDIClientRef = 0
    private var inputPort: MIDIPortRef = 0
    private var outputPort: MIDIPortRef = 0
    
    private let maxMessages = 1000
    
    init() {
        setupMIDI()
        refreshDevices()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - MIDI Setup
    private func setupMIDI() {
        var client: MIDIClientRef = 0
        let clientName = "KnobeatMIDI" as CFString
        
        var status = MIDIClientCreateWithBlock(clientName, &client) { [weak self] notification in
            self?.handleMIDINotification(notification)
        }
        
        guard status == noErr else {
            print("Failed to create MIDI client: \(status)")
            return
        }
        
        midiClient = client
        
        // Create input port
        let inputPortName = "Input" as CFString
        status = MIDIInputPortCreateWithProtocol(
            midiClient,
            inputPortName,
            MIDIProtocolID._1_0,
            &inputPort
        ) { [weak self] eventList, srcConnRefCon in
            self?.handleMIDIPacketList(eventList)
        }
        
        guard status == noErr else {
            print("Failed to create input port: \(status)")
            return
        }
        
        // Create output port
        let outputPortName = "Output" as CFString
        status = MIDIOutputPortCreate(midiClient, outputPortName, &outputPort)
        
        guard status == noErr else {
            print("Failed to create output port: \(status)")
            return
        }
        
        isConnected = true
    }
    
    // MARK: - Device Management
    func refreshDevices() {
        DispatchQueue.main.async { [weak self] in
            self?.updateSources()
            self?.updateDestinations()
        }
    }
    
    private func updateSources() {
        var newSources: [MIDIDeviceInfo] = []
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0..<sourceCount {
            let endpoint = MIDIGetSource(i)
            if let deviceInfo = getDeviceInfo(endpoint: endpoint, index: i) {
                newSources.append(deviceInfo)
                
                // Auto-select DDJ-SR if found
                if deviceInfo.isDDJSR {
                    ddjSRDetected = true
                    if selectedSourceIndex == nil {
                        selectedSourceIndex = i
                        connectToSource(i)
                    }
                }
            }
        }
        
        sources = newSources
    }
    
    private func updateDestinations() {
        var newDestinations: [MIDIDeviceInfo] = []
        let destCount = MIDIGetNumberOfDestinations()
        
        for i in 0..<destCount {
            let endpoint = MIDIGetDestination(i)
            if let deviceInfo = getDeviceInfo(endpoint: endpoint, index: i) {
                newDestinations.append(deviceInfo)
                
                // Auto-select DDJ-SR if found
                if deviceInfo.isDDJSR && selectedDestinationIndex == nil {
                    selectedDestinationIndex = i
                }
            }
        }
        
        destinations = newDestinations
    }
    
    private func getDeviceInfo(endpoint: MIDIEndpointRef, index: Int) -> MIDIDeviceInfo? {
        var name: Unmanaged<CFString>?
        var manufacturer: Unmanaged<CFString>?
        
        MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDisplayName, &name)
        MIDIObjectGetStringProperty(endpoint, kMIDIPropertyManufacturer, &manufacturer)
        
        let deviceName = name?.takeRetainedValue() as String? ?? "Unknown Device"
        let mfg = manufacturer?.takeRetainedValue() as String? ?? ""
        
        // Check if this is a Pioneer DDJ-SR
        let isDDJSR = deviceName.lowercased().contains("ddj-sr") || 
                      deviceName.lowercased().contains("ddj sr") ||
                      (deviceName.lowercased().contains("pioneer") && deviceName.lowercased().contains("dj"))
        
        return MIDIDeviceInfo(
            id: index,
            name: deviceName,
            manufacturer: mfg,
            isDDJSR: isDDJSR
        )
    }
    
    // MARK: - Input Connection
    func connectToSource(_ index: Int) {
        guard index < MIDIGetNumberOfSources() else { return }
        
        // Disconnect from previous source
        if let prevIndex = selectedSourceIndex {
            let prevSource = MIDIGetSource(prevIndex)
            MIDIPortDisconnectSource(inputPort, prevSource)
        }
        
        let source = MIDIGetSource(index)
        let status = MIDIPortConnectSource(inputPort, source, nil)
        
        if status == noErr {
            selectedSourceIndex = index
            print("Connected to MIDI source: \(sources[index].name)")
        } else {
            print("Failed to connect to source: \(status)")
        }
    }
    
    // MARK: - MIDI Message Handling
    private func handleMIDIPacketList(_ packetList: UnsafePointer<MIDIEventList>) {
        let eventList = packetList.pointee
        var packet = eventList.packet
        
        for _ in 0..<eventList.numPackets {
            withUnsafePointer(to: &packet) { ptr in
                handleMIDIPacket(ptr.pointee)
            }
            packet = MIDIEventListNext(&packet).pointee
        }
    }
    
    private func handleMIDIPacket(_ packet: MIDIEventPacket) {
        let wordCount = packet.wordCount
        guard wordCount > 0 else { return }
        
        // Extract MIDI data from the packet
        var words: [UInt32] = []
        withUnsafeBytes(of: packet.words) { buffer in
            let count = Int(wordCount)
            for i in 0..<count {
                if i * 4 < buffer.count {
                    let word = buffer.load(fromByteOffset: i * 4, as: UInt32.self)
                    words.append(word)
                }
            }
        }
        
        // Parse MIDI messages from words
        for word in words {
            let bytes = [
                UInt8((word >> 0) & 0xFF),
                UInt8((word >> 8) & 0xFF),
                UInt8((word >> 16) & 0xFF),
                UInt8((word >> 24) & 0xFF)
            ]
            
            // Check if this is a status byte (bit 7 set)
            if bytes[0] & 0x80 != 0 {
                let statusByte = bytes[0]
                let data1 = bytes.count > 1 ? bytes[1] : 0
                let data2 = bytes.count > 2 ? bytes[2] : 0
                
                addMessage(statusByte: statusByte, data1: data1, data2: data2)
            }
        }
    }
    
    private func addMessage(statusByte: UInt8, data1: UInt8, data2: UInt8) {
        let sourceIndex = selectedSourceIndex ?? -1
        let sourceName = sourceIndex >= 0 && sourceIndex < sources.count 
            ? sources[sourceIndex].name 
            : "Unknown"
        
        let rawHex = String(format: "%02X %02X %02X", statusByte, data1, data2)
        let decoded = decodeMessage(statusByte: statusByte, data1: data1, data2: data2)
        
        let message = MIDIMessage(
            timestamp: Date(),
            sourceIndex: sourceIndex,
            sourceName: sourceName,
            statusByte: statusByte,
            data1: data1,
            data2: data2,
            rawHex: rawHex,
            decoded: decoded
        )
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messages.insert(message, at: 0)
            
            // Keep only the latest messages
            if self.messages.count > self.maxMessages {
                self.messages.removeLast(self.messages.count - self.maxMessages)
            }
        }
    }
    
    private func decodeMessage(statusByte: UInt8, data1: UInt8, data2: UInt8) -> String {
        let messageType = statusByte & 0xF0
        let channel = (statusByte & 0x0F) + 1
        
        switch messageType {
        case 0x80:
            return "Note Off, Ch \(channel), Note \(data1), Vel \(data2)"
        case 0x90:
            if data2 == 0 {
                return "Note Off, Ch \(channel), Note \(data1), Vel 0"
            } else {
                return "Note On, Ch \(channel), Note \(data1), Vel \(data2)"
            }
        case 0xA0:
            return "Poly Aftertouch, Ch \(channel), Note \(data1), Pressure \(data2)"
        case 0xB0:
            return "Control Change, Ch \(channel), CC \(data1), Value \(data2)"
        case 0xC0:
            return "Program Change, Ch \(channel), Program \(data1)"
        case 0xD0:
            return "Channel Aftertouch, Ch \(channel), Pressure \(data1)"
        case 0xE0:
            let value = Int(data1) | (Int(data2) << 7)
            return "Pitch Bend, Ch \(channel), Value \(value)"
        case 0xF0:
            if statusByte == 0xF0 {
                return "System Exclusive (SysEx) Start"
            } else if statusByte == 0xF7 {
                return "System Exclusive (SysEx) End"
            } else {
                return "System Message: \(String(format: "%02X", statusByte))"
            }
        default:
            return "Unknown: \(String(format: "%02X", statusByte))"
        }
    }
    
    // MARK: - MIDI Output
    func sendMessage(destination: Int, statusByte: UInt8, data1: UInt8, data2: UInt8) {
        guard destination < MIDIGetNumberOfDestinations() else { return }
        
        let dest = MIDIGetDestination(destination)
        
        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)
        
        let midiData: [UInt8] = [statusByte, data1, data2]
        packet = MIDIPacketListAdd(
            &packetList,
            1024,
            packet,
            0,
            midiData.count,
            midiData
        )
        
        let status = MIDISend(outputPort, dest, &packetList)
        
        if status != noErr {
            print("Failed to send MIDI message: \(status)")
        }
    }
    
    func sendNoteOn(destination: Int, channel: UInt8, note: UInt8, velocity: UInt8) {
        let statusByte = 0x90 | (channel & 0x0F)
        sendMessage(destination: destination, statusByte: statusByte, data1: note, data2: velocity)
    }
    
    func sendNoteOff(destination: Int, channel: UInt8, note: UInt8) {
        let statusByte = 0x80 | (channel & 0x0F)
        sendMessage(destination: destination, statusByte: statusByte, data1: note, data2: 0)
    }
    
    func sendControlChange(destination: Int, channel: UInt8, cc: UInt8, value: UInt8) {
        let statusByte = 0xB0 | (channel & 0x0F)
        sendMessage(destination: destination, statusByte: statusByte, data1: cc, data2: value)
    }
    
    // MARK: - Notification Handling
    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        let notif = notification.pointee
        
        switch notif.messageID {
        case .msgObjectAdded, .msgObjectRemoved:
            refreshDevices()
        case .msgSetupChanged:
            refreshDevices()
        default:
            break
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        if inputPort != 0 {
            MIDIPortDispose(inputPort)
        }
        if outputPort != 0 {
            MIDIPortDispose(outputPort)
        }
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
}
