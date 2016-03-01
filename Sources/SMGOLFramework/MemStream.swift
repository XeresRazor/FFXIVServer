//
//  MemStream.swift
//  SMGOLFramework
//
//  Created by David Green on 2/29/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

private let growSize = 0x1000

public class MemStream: Stream {
    private(set) public var size: UInt = 0
    private var grow: UInt = 0
    private var position: UInt = 0
    private var data: [UInt8]?
    private var eof = false
    
    public init() {}
    
    public convenience init(source: MemStream) {
        self.init()
        self.copyFrom(source)
    }
    
    private func copyFrom(source: MemStream) {
        assert(data != nil)
        size = source.size
        grow = source.grow
        position = source.position
        assert(grow >= size)
        assert(position <= size)
        data = [UInt8](count: numericCast(grow), repeatedValue: 0)
        memcpy(&data!, &source.data!, numericCast(size))
        eof = source.eof
    }
    
    public func isEOF() -> Bool {
        return eof
    }
    
    public func tell() -> UInt64 {
        return numericCast(position)
    }
    
    public func seek(position: Int64, direction: StreamSeekDirection) {
        switch direction {
        case .Set:
            guard position <= Int64(size) else { return }
            self.position = numericCast(position)
            eof = false
        case .Cur:
            self.position += numericCast(position)
            eof = false
        case .End:
            self.position = size
            eof = true
        }
    }
    
    public func read(inout buffer: [UInt8]) throws {
        guard position < size else { eof = true; return }
        let readSize = min(numericCast(buffer.count), size - position)
        if numericCast(readSize) < buffer.count {
            buffer.removeLast(buffer.count - numericCast(readSize))
        }
        memcpy(&buffer, &data![numericCast(position)], numericCast(readSize))
        position += numericCast(readSize)
    }
    
    public func write(buffer: [UInt8]) -> Int {
        if (position + numericCast(buffer.count)) > grow {
            assert(grow >= size)
            grow += numericCast(((numericCast(buffer.count) + growSize + 1) / growSize) * growSize)
            data?.reserveCapacity(numericCast(grow))
        }
        memcpy(&data![numericCast(position)], buffer, numericCast(buffer.count))
        position += numericCast(buffer.count)
        size = max(size, position)
        return numericCast(size)
    }
    
    public func allocate(size: UInt) {
        assert(size >= self.size)
        data?.reserveCapacity(numericCast(size))
        grow = size
        self.size = size
    }
    
    public func resetBuffer() {
        size = 0
        position = 0
        eof = false
    }
    
    public func truncate() {
        size = numericCast(remainingLength())
        assert(size <= grow)
        memmove(&data!, &data![numericCast(position)], numericCast(size))
        position = 0
    }
    
    public func buffer() -> [UInt8]? {
        return data
    }
}
