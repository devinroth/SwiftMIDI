//
//  SwiftMIDI.swift
//
//  Copyright © 2017 Devin Roth. All rights reserved.
//

import Foundation
import CoreMIDI

//MARK: MIDI CONSTANTS
struct MidiCommand {
    
    //command byte
    static let noteOff = 0b1000
    static let noteOn = 0b1001
    static let aftertouch = 0b1010
    static let controlChange = 0b1011
    static let programChange = 0b1100
    static let channelPressure = 0b1101
    static let pitchBend = 0b1110
    static let system = 0b1111
    
    //system messages
    struct systemExclusive {
        static let systemExclusiveStart = 0b0000
        static let timecode = 0b0001
        static let songPosition = 0b0010
        static let songSelect = 0b0011
        static let tuneRequest = 0b0110
        static let systemExclusiveEnd = 0b0111
        static let timingClock = 0b1000
        static let start = 0b1010
        static let cont = 0b1011
        static let stop = 0b1100
        static let activeSensing = 0b1110
        static let reset = 0b1111
        
        struct universal {
            static let nonCommercial = 0x7D
            static let nonRealtime = 0x7E
            static let realtime = 0x7F
        }
    }
    
    //channel mode
    struct channelMode {
        static let allSoundsOff = 120
        static let resetAllControllers = 121
        static let localControl = 122
        static let allNotesOff = 123
        static let omniOff = 124
        static let omniOn = 125
        static let monoOn = 126
        static let monoOff = 127
    }
}

//MARK: Midi Delegate
protocol MidiDelegate {

    //commands
    func midiDidReceive(_ packet:MIDIPacket)
    func midiDidReceiveNoteOff(_ channel:Int, note:Int)
    func midiDidReceiveNoteOn(_ channel:Int, note:Int, velocity:Int)
    func midiDidReceiveAftertouch(_ channel:Int, note:Int, pressure:Int)
    func midiDidReceiveControlChange(_ channel:Int, cc:Int, value:Int)
    func midiDidReceiveProgramChange(_ channel:Int, program:Int)
    func midiDidReceiveChannelPressure(_ channel:Int, pressure:Int)
    func midiDidReceivePitchBend(_ channel:Int, value:Int)
    
    //system
    func midiDidReceiveSystemExclusive(_ message:String)
    func midiDidReceiveTimecode(_ hh:Int, mm:Int, ss:Int, ff:Int, fps:String)
    func midiDidReceiveSongPosition(_ beats:Int)
    func midiDidReceiveSongSelect(_ song:Int)
    func midiDidReceiveTuneRequest()
    func midiDidReceiveTimingClock()
    func midiDidReceiveStart()
    func midiDidReceiveContinue()
    func midiDidReceiveStop()
    func midiDidReceiveActiveSensing()
    func midiDidReceiveReset()
    
    //channel mode
    func midiDidReceiveAllSoundsOff()
    func midiDidReceiveResetAllControllers()
    func midiDidReceiveLocalControl(_ status:Bool)
    func midiDidReceiveAllNotesOff()
    func midiDidReceiveOmniMode(_ status:Bool)
    func midiDidReceiveMonoMode(_ status:Bool)
    
}
extension MidiDelegate {
    
    //commands
    func midiDidReceive(_ packet:MIDIPacket){
    }
    func midiDidReceiveNoteOff(_ channel:Int, note:Int){
    }
    func midiDidReceiveNoteOn(_ channel:Int, note:Int, velocity:Int){
    }
    func midiDidReceiveAftertouch(_ channel:Int, note:Int, pressure:Int){
    }
    func midiDidReceiveControlChange(_ channel:Int, cc:Int, value:Int){
    }
    func midiDidReceiveProgramChange(_ channel:Int, program:Int){
    }
    func midiDidReceiveChannelPressure(_ channel:Int, pressure:Int){
    }
    func midiDidReceivePitchBend(_ channel:Int, value:Int){
    }
    
    //system
    func midiDidReceiveSystemExclusive(_ message:String){
    }
    func midiDidReceiveTimecode(_ hh:Int, mm:Int, ss:Int, ff:Int, fps:String){
    }
    func midiDidReceiveSongPosition(_ beats:Int){
    }
    func midiDidReceiveSongSelect(_ song:Int){
    }
    func midiDidReceiveTuneRequest(){
    }
    func midiDidReceiveTimingClock(){
    }
    func midiDidReceiveStart(){
    }
    func midiDidReceiveContinue(){
    }
    func midiDidReceiveStop(){
    }
    func midiDidReceiveActiveSensing(){
    }
    func midiDidReceiveReset(){
    }
    
    //channel mode
    func midiDidReceiveAllSoundsOff(){
    }
    func midiDidReceiveResetAllControllers(){
    }
    func midiDidReceiveLocalControl(_ status:Bool){
    }
    func midiDidReceiveAllNotesOff(){
    }
    func midiDidReceiveOmniMode(_ status:Bool){
    }
    func midiDidReceiveMonoMode(_ status:Bool){
    }
}

public class Midi {
    
    //MARK: Properties
    var client = MIDIClientRef()
    var destination = MIDIEndpointRef()
    var source = MIDIEndpointRef()
    
    var hh = 0
    var mm = 0
    var ss = 0
    var ff = 0
    var fps = "0"
    
    var delegate:MidiDelegate?
    
    //MARK: Init
    init(clientName: CFString){
        createClient(clientName)
    }
    

    //MARK: Methods
    
    
    //create the midi client
    private func createClient(_ name: CFString) {
        var status = OSStatus(noErr)
        status = MIDIClientCreate(name, nil, nil, &client)
        if status == OSStatus(noErr) {
//            print("created client \(client)")
        } else {
            print("error creating client : \(status)")
            print(showError(status))
        }
    }
    
    //create midi destination
    func createDestination(_ name: CFString) {
        var status = OSStatus(noErr)
        status = MIDIDestinationCreate(client, name, midiMIDIReadProc, nil, &destination)
        if status == OSStatus(noErr) {
//            print("created destination \(destination)")
            var param: Unmanaged<CFString>?
            let err: OSStatus = MIDIObjectGetStringProperty(destination, kMIDIPropertyUniqueID, &param)
            if err == OSStatus(noErr)
            {
                print(param!.takeRetainedValue() as String)
            }
        } else {
            print("error creating destination : \(status)")
            print(showError(status))
        }
    }
    
    //create midi source
    func createSource(_ name: String) {
        var status = OSStatus(noErr)
        status = MIDISourceCreate(client, name as CFString, &source)
        if status == OSStatus(noErr) {
//            print("created source \(source)")
        } else {
            print("error creating source : \(status)")
            _ = showError(status)
        }
    }
    
    //errors
    private func showError(_ status:OSStatus)->String {
        var error = ""
        
        switch status {
        case OSStatus(kMIDIInvalidClient):
            error = "invalid client"
            break
        case OSStatus(kMIDIInvalidPort):
            error = "invalid port"
            break
        case OSStatus(kMIDIWrongEndpointType):
            error = "invalid endpoint type"
            break
        case OSStatus(kMIDINoConnection):
            error = "no connection"
            break
        case OSStatus(kMIDIUnknownEndpoint):
            error = "unknown endpoint"
            break
        case OSStatus(kMIDIUnknownProperty):
            error = "unknown property"
            break
        case OSStatus(kMIDIWrongPropertyType):
            error = "wrong property type"
            break
        case OSStatus(kMIDINoCurrentSetup):
            error = "no current setup"
            break
        case OSStatus(kMIDIMessageSendErr):
            error = "message send"
            break
        case OSStatus(kMIDIServerStartErr):
            error = "server start"
            break
        case OSStatus(kMIDISetupFormatErr):
            error = "setup format"
            break
        case OSStatus(kMIDIWrongThread):
            error = "wrong thread"
            break
        case OSStatus(kMIDIObjectNotFound):
            error = "object not found"
            break
        case OSStatus(kMIDIIDNotUnique):
            error = "not unique"
            break
        case OSStatus(kMIDINotPermitted):
            error = "not permitted"
            break
        default:
            error = "dunno \(status)"
        }
        return error
    }
    
    //midi in
    func midiIn(_ packetList: UnsafePointer<MIDIPacketList>){
        
        let packets = packetList.pointee
        let packet:MIDIPacket = packets.packet
        
        var ap = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        ap.initialize(to: packet)
        
        for _ in 0 ..< packets.numPackets {
            
            let p = ap.pointee
            
            delegate?.midiDidReceive(p)
            
            let midiStatus = Int(p.data.0)
            let command = Int(midiStatus/16)
            
            
            
            //parse incoming midi data
            switch command {
                case MidiCommand.noteOff:
                    let channel = Int((midiStatus%16)+1)
                    let note = Int(p.data.1)
                    delegate?.midiDidReceiveNoteOff(channel, note: note)
                
                case MidiCommand.noteOn:
                    let channel = Int((midiStatus%16)+1)
                    let note = Int(p.data.1)
                    let velocity = Int(p.data.2)
                    delegate?.midiDidReceiveNoteOn(channel, note: note, velocity: velocity)

                case MidiCommand.aftertouch:
                    let channel = Int((midiStatus%16)+1)
                    let note = Int(p.data.1)
                    let pressure = Int(p.data.2)
                    delegate?.midiDidReceiveAftertouch(channel, note: note, pressure: pressure)
                
                case MidiCommand.controlChange:
                    let channel = Int((midiStatus%16)+1)
                    let cc = Int(p.data.1)
                    let value = Int(p.data.2)
                    switch cc {
                        case MidiCommand.channelMode.allSoundsOff:
                            delegate?.midiDidReceiveAllSoundsOff()
                        
                        case MidiCommand.channelMode.resetAllControllers:
                            delegate?.midiDidReceiveResetAllControllers()
                        
                        case MidiCommand.channelMode.localControl:
                            if value == 127 {
                                delegate?.midiDidReceiveLocalControl(true)
                            } else if value == 0 {
                                delegate?.midiDidReceiveLocalControl(false)
                            }
                        
                        case MidiCommand.channelMode.allNotesOff:
                            delegate?.midiDidReceiveAllNotesOff()
                        
                        case MidiCommand.channelMode.omniOff:
                            delegate?.midiDidReceiveOmniMode(false)
                        
                        case MidiCommand.channelMode.omniOn:
                            delegate?.midiDidReceiveOmniMode(true)
                        
                        case MidiCommand.channelMode.monoOn:
                            delegate?.midiDidReceiveMonoMode(true)
                        
                        case MidiCommand.channelMode.monoOff:
                            delegate?.midiDidReceiveMonoMode(false)
                        
                        default:
                            DispatchQueue.main.async {
                                self.delegate?.midiDidReceiveControlChange(channel, cc: cc, value: value)
                            }
                        
                    }
                
                case MidiCommand.programChange:
                    let channel = Int((midiStatus%16)+1)
                    let program = Int(p.data.1)
                    delegate?.midiDidReceiveProgramChange(channel, program:program)
                
                case MidiCommand.channelPressure:
                    let channel = Int((midiStatus%16)+1)
                    let pressure = Int(p.data.1)
                    delegate?.midiDidReceiveChannelPressure(channel, pressure:pressure)
                
                case MidiCommand.pitchBend:
                    let channel = Int((midiStatus%16)+1)
                    let lsb = Int(p.data.1)
                    let msb = Int(p.data.2)
                    let value = msb*128 + lsb
                    delegate?.midiDidReceivePitchBend(channel, value:value)
                
                case MidiCommand.system:
                    let systemCommand = Int(midiStatus%16)
                    
                    switch systemCommand {
                        case MidiCommand.systemExclusive.systemExclusiveStart:
                            let id = Int(p.data.1)
                            switch id {
                            case MidiCommand.systemExclusive.universal.realtime:
//                                Int(p.data.2) == 0x7F//channel 0x7F sends to whole system
//                                Int(p.data.3) == 0x01//timecode id of 0x01
//                                Int(p.data.4) == 0x01//0x01 code for full frame message
                                
                                let data = Int(p.data.5)//fps and hh
                                
                                hh = data%32
                                let frameRate = data/32
                                
                                switch frameRate {
                                case 0:
                                    fps = "24 fps"
                                case 1:
                                    fps = "25 fps"
                                case 2:
                                    fps = "30 fps drop"
                                case 3:
                                    fps = "30 fps"
                                default:
                                    print("Unknown Frame Rate")
                                }
                                
                                mm = Int(p.data.6)
                                ss = Int(p.data.7)
                                ff = Int(p.data.8)
//                                Int(p.data.9) == 0xF7
                                
                                delegate?.midiDidReceiveTimecode(hh, mm:mm, ss:ss, ff:ff, fps:fps)
                                
                            default:
                                print("unknown system message")
                            
                            }
                        
                        case MidiCommand.systemExclusive.timecode:
                            let value = Int(p.data.1) >> 4
                            let data = Int(p.data.1)%16
                            
                            switch value {
                            //Frames Low Nibble
                            case 0:
                                
                                //fixes based on framerates
                                switch fps {
                                case "24 fps":
                                    if ff == 23 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                case "25 fps":
                                    if ff == 24 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                default:
                                    if ff == 29 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                }
                                //fix for fame high nibble delay
                                if ff == 15 {
                                    ff = 16
                                }
                                
                                //fix for
                                
                                let msb:Int = ff/16
                                ff = msb*16 + data
                                
                                //only send to delegate when fames are received. fixes timecode bugs
                                delegate?.midiDidReceiveTimecode(hh, mm:mm, ss:ss, ff:ff, fps: fps)
                                
                            //Frames High Nibble
                            case 1:
                                let lsb = ff%16
                                ff = data*16 + lsb + 1
                                
                                //fixes based on framerate
                                switch fps {
                                case "24 fps":
                                    if ff == 24 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                case "25 fps":
                                    if ff == 25 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                default:
                                    if ff == 30 {
                                        ff = 0
                                        rolloverTimecode()
                                    }
                                }
                                //only send to delegate when fames are received. fixes timecode bugs
                                delegate?.midiDidReceiveTimecode(hh, mm:mm, ss:ss, ff:ff, fps: fps)
                                
                                
                            //Seconds Low Nibble
                            case 2:
                                let msb: Int = ss/16
                                ss = msb*16+data
                                
                            //Seconds High Nibble
                            case 3:
                                let lsb = ss%16
                                ss = lsb + (data*16)
                                
                            //Minutes Low Nibble
                            case 4:
                                let msb:Int = mm/16
                                mm = msb*16+data
                                
                            //Minutes High Nibble
                            case 5:
                                let lsb = mm%16
                                mm = lsb+(data*16)
                                
                            //Hours Low Nibble
                            case 6:
                                let msb:Int = hh/16
                                hh = msb*16+data
                                
                            //Hours High Nibble and SMPTE Type
                            case 7:
                                let lsb = hh%16
                                hh = lsb+(data%2)*16
                                let frameRate = data/2
                                
                                switch frameRate {
                                case 0:
                                    fps = "24 fps"
                                case 1:
                                    fps = "25 fps"
                                case 2:
                                    fps = "30 fps drop"
                                case 3:
                                    fps = "30 fps"
                                default:
                                    print("Unknown Frame Rate")
                                }
                            
                            default:
                                print("Unknown Timecode Data")
                            }
                        
                        case MidiCommand.systemExclusive.songPosition:
                            let lsb = Int(p.data.1)
                            let msb = Int(p.data.2)
                            let beats = msb*16 + lsb
                            delegate?.midiDidReceiveSongPosition(beats)
                        
                        case MidiCommand.systemExclusive.songSelect:
                            let song = Int(p.data.1)
                            delegate?.midiDidReceiveSongSelect(song)
                        
                        case MidiCommand.systemExclusive.tuneRequest:
                            delegate?.midiDidReceiveTuneRequest()
                        
                        case MidiCommand.systemExclusive.timingClock:
                            delegate?.midiDidReceiveTimingClock()
                        
                        case MidiCommand.systemExclusive.start:
                            delegate?.midiDidReceiveStart()
                        
                        case MidiCommand.systemExclusive.cont:
                            delegate?.midiDidReceiveContinue()
                        
                        case MidiCommand.systemExclusive.stop:
                            delegate?.midiDidReceiveStop()
                        
                        case MidiCommand.systemExclusive.activeSensing:
                            delegate?.midiDidReceiveActiveSensing()
                        
                        case MidiCommand.systemExclusive.reset:
                            delegate?.midiDidReceiveReset()
                        
                        default:
                            print("Unknown MIDI System Message")
                    }
                
                default:
                    print("Unknown MIDI Data")
            }
            
            //advance to next packet
            ap = MIDIPacketNext(ap)
            
        }
    }
    
    //midi out
    func midiOut(_ status:Int, byte1: Int, byte2:Int) {
        var packet = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        let packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        let midiDataToSend:[UInt8] = [UInt8(status), UInt8(byte1), UInt8(byte2)];
        packet = MIDIPacketListInit(packetList);
        packet = MIDIPacketListAdd(packetList, 1024, packet, mach_absolute_time(), 3, midiDataToSend);
    
//        if (packet == nil ) {
//            print("failed to send the midi.")
//        } else {
//            MIDIReceived(source, packetList)
//        }
        MIDIReceived(source, packetList)
        packet.deinitialize()
        packetList.deinitialize()
        packetList.deallocate(capacity: 1)
    }
    
    //helper methods
    
    //fix to handle the delay in receiving timecode messages
    private func rolloverTimecode(){
        ss += 1
        if ss == 60 {
            mm += 1
            ss = 0
            if mm == 60 {
                hh += 1
                mm = 0
                if hh == 24 {
                    hh = 0
                }
            }
        }
    }
}

var midi = Midi(clientName: "test" as CFString)

//called when midi enters
func midiMIDIReadProc(packetList: UnsafePointer<MIDIPacketList>, readProcRefCon: UnsafeMutableRawPointer?, srcConnRefCon: UnsafeMutableRawPointer?) {
    
    midi.midiIn(packetList)
}

public func testFramework() {
    print("Works")
}
