//
//  StandardStream.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

enum StandardStreamError : ErrorType {
    case EndOfFile
}

public class StandardStream: Stream {
    public var file: UnsafeMutablePointer<FILE> = nil
    
    public init(stream: StandardStream) {
        file = stream.file
    }
    
    public init?(file: UnsafeMutablePointer<FILE>) {
        if file == nil {
            print("Invalid file handle.")
            return nil
        }
        self.file = file
    }
    
    public init?(path: String, options: String) {
        file = fopen(path, options)
        if file == nil {
            print("Invalid file at path: \(path)")
             return nil
        }
    }
    
    deinit {
        clear()
    }
    
    public func clear() {
        if file != nil {
            fclose(file)
            file = nil
        }
    }
    
    public func isEmpty() -> Bool {
        return (file == nil)
    }
    
    public func seek(position: Int64, direction: StreamSeekDirection) {
        guard file != nil else {assert(true); return}
        
        var dir: Int32
        switch direction {
        case .Set:
            dir = SEEK_SET
        case .Cur:
            dir = SEEK_CUR
        case .End:
            dir = SEEK_END
        }
        
        let result = fseek(file, Int(position), dir)
        assert(result == 0)
        assert((direction != .Set) || (ftello(file) == position))
    }
    
    public func isEOF() -> Bool {
        guard file != nil else {assert(true); return false}
        return (feof(file) != 0)
    }
    
    public func tell() -> UInt64 {
        guard file != nil else {assert(true); return 0}
        return UInt64(ftello(file))
    }
    
    public func read(inout buffer: [UInt8]) throws {
        guard file != nil else {assert(true); return}
        if feof(file) != 0 || ferror(file) != 0 {
            throw StandardStreamError.EndOfFile
        }
        fread(&buffer, 1, buffer.count, file)
    }
    
    public func write(buffer: [UInt8]) -> Int {
        guard file != nil else {assert(true); return 0}
        return fwrite(buffer, 1, buffer.count, file)
    }
    
    public func flush() {
        guard file != nil else {assert(true); return}
        fflush(file)
    }
    
    public func close() {
        guard file != nil else {assert(true); return}
        clear()
    }
}
