//
//  Stream.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public enum StreamSeekDirection: Int {
    case Set = 0
    case End = 1
    case Cur = 2
}

public protocol Stream: class {
    func seek(position: Int64, direction: StreamSeekDirection)
    func tell() -> UInt64
    func read(length: Int) throws -> [UInt8]
    func read(inout buffer: [UInt8]) throws
    func write(buffer: [UInt8]) -> Int
    func isEOF() -> Bool
    func flush()
    func length() -> UInt64
    func remainingLength() -> UInt64
}

public extension Stream {
    public func read8() throws -> UInt8 {
        let value = try read(1)
        return value[0]
    }
    
    public func read16() throws -> UInt16 {
        let value = try read(2)
        var val: UInt16 = 0
        memcpy(&val, value, 2)
        return val
    }
    
    public func read32() throws -> UInt32 {
        let value = try read(4)
        var val: UInt32 = 0
        memcpy(&val, value, 4)
        return val

    }
    
    public func read64() throws -> UInt64 {
        let value = try read(8)
        var val: UInt64 = 0
        memcpy(&val, value, 8)
        return val
    }
    
    public func read16MSBF() throws -> UInt16 {
        let value = try read(2)
        var val: UInt16 = 0
        memcpy(&val, value, 4)
        val = (((val & 0xFF00) >> 8) << 0) |
              (((val & 0x00FF) >> 0) << 8)
        return val
    }
    
    public func read32MSBF() throws -> UInt32 {
        let value = try read(4)
        var val: UInt32 = 0
        memcpy(&val, value, 4)
        val = (((val & 0xFF000000) >> 24) << 0) |
              (((val & 0x00FF0000) >> 16) << 8) |
              (((val & 0x0000FF00) >> 8) << 16) |
              (((val & 0x000000FF) >> 0) << 24)
        return val
    }
    
    public func readFloat() throws -> Float {
        let size = sizeof(Float)
        let value = try read(size)
        var f: Float = 0.0
        memcpy(&f, value, size)
        return f
    }
    
    public func readString() throws -> String {
        var result = ""
        while true {
            let next = CChar(try read8())
            if isEOF() {
                break
            }
            if next == 0 {
                break
            }
            let charString = String.fromCString([next])
            result = "\(result)\(charString)"
        }
        return result
    }
    
    public func readString(length: Int) throws -> String {
        if length == 0 {
            return ""
        }
        var stringBuffer = try read(length)
        return withUnsafePointer(&stringBuffer) { String.fromCString(UnsafePointer($0))! }
        
    }
    
    public func write8(value: UInt8) {
        write([value])
    }
    
    public func write16(value: UInt16) {
        write(toByteArray(value))
    }
    
    public func write32(value: UInt32) {
        write(toByteArray(value))
    }
    
    public func write64(value: UInt64) {
        write(toByteArray(value))
    }
}

// MARK: Default implementations
public extension Stream {
    public func flush() {}
    
    public func length() -> UInt64 {
        let position = tell()
        seek(0, direction:.End)
        let size = tell()
        seek(Int64(position), direction: .Set)
        return size
    }
    
    public func remainingLength() -> UInt64 {
        let position = tell()
        seek(0, direction: .End)
        let size = tell()
        seek(Int64(position), direction: .Set)
        return size - position
    }
    
    public func read(length: Int) throws -> [UInt8] {
        var buffer = [UInt8](count: length, repeatedValue: 0)
        try read(&buffer)
        return buffer
    }
}

private func toByteArray<T>(value: T) -> [UInt8] {
    var val = value
    return withUnsafePointer(&val) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}
