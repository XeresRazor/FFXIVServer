//
//  PacketUtils.swift
//  FFXIVServer
//
//  Created by David Green on 2/29/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

struct PacketHeader {
    var packetType: UInt32
    var packetSize: UInt16
    var unknown0: UInt16
    var unknown1: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    
    init?(fromStream: Stream) {
        do {
            try packetType = fromStream.read32()
            try packetSize = fromStream.read16()
            try unknown0 = fromStream.read16()
            try unknown1 = (fromStream.read32(), fromStream.read32(), fromStream.read32(), fromStream.read32(), fromStream.read32(), fromStream.read32())
        } catch {
            return nil
        }
    }
}

struct SubPacketHeader {
    var subPacketSize: UInt16
    var unknown0: UInt16
    var unknown1: UInt32
    var unknown2: UInt32
    var unknown3: UInt32
    
    init?(fromStream: Stream) {
        do {
            try subPacketSize = fromStream.read16()
            try unknown0 = fromStream.read16()
            try unknown1 = fromStream.read32()
            try unknown2 = fromStream.read32()
            try unknown3 = fromStream.read32()
        } catch {
            return nil
        }
    }
}

typealias PacketData = [UInt8]
typealias SubPacketArray = [PacketData]

struct PacketUtils {
    static let LogName = "PacketUtils"
    
    static func hasPacket(stream: MemStream) -> Bool {
        print("Sizeof PacketHeader:\(sizeof(PacketHeader)). Sizeof SubPacketHeader:\(sizeof(SubPacketHeader))")
        if stream.size < numericCast(sizeof(PacketHeader)) {
            return false
        }
        
        stream.seek(0, direction: .Set)
        
        guard let header = PacketHeader(fromStream: stream) else {
            return false
        }
        stream.seek(0, direction: .End)
        
        if stream.size < numericCast(header.packetSize) {
            return false
        }
        return true
    }
    
    static func readPacket(stream: MemStream) -> PacketData {
        var result = PacketData()
        
        guard hasPacket(stream) else {
            assert(false)
            return result
        }
        
        stream.seek(0, direction: .Set)
        guard let header = PacketHeader(fromStream: stream) else {
            return result
        }
        guard header.packetSize >= numericCast(sizeof(PacketHeader)) else {
            // Invalid Packet
            Log.instance().logError(LogName, message: "Packet size in header is invalid.")
            return result
        }
        
        stream.seek(0, direction: .Set)
        do {
            try result = stream.read(numericCast(header.packetSize))
        } catch {
            return PacketData()
        }
        stream.truncate()
        
        stream.seek(0, direction: .End)
        
        return result
        
        
    }
    
    /*static func splitPacket(packet: PacketData) -> SubPacketArray {
        
    }
    
    static func dumpPacket(packet: PacketData) -> String {
        
    }
    
    static func getSubPacketCommand(packet: PacketData) -> UInt16 {
        
    }
    
    static func encryptPacket(inout packet: PacketData) {
        
    }
    
    static func decryptSubPacket(packet: PacketData) -> PacketData {
        
    }*/
}