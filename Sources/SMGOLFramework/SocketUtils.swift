//
//  SocketUtils.swift
//  SMGOLFramework
//
//  Created by David Green on 2/29/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public func GetSocketIPAddressString(address: Socket.SocketAddress) -> String {
    var result = UnsafeMutablePointer<Int8>()
    while true {
        var error = UnsafePointer<Int8>()
        var addressStringLength = Int32(0)
        switch address.type {
        case .ipv4:
            addressStringLength = INET_ADDRSTRLEN
            result = UnsafeMutablePointer<Int8>.alloc(Int(addressStringLength))
            var socketAddress = address.ip4SockAddr
            error = inet_ntop(Int32(socketAddress.sin_family), &socketAddress.sin_addr, UnsafeMutablePointer<Int8>(result), UInt32(addressStringLength))
            
        case .ipv6:
            addressStringLength = INET6_ADDRSTRLEN
            result = UnsafeMutablePointer<Int8>.alloc(Int(addressStringLength))
            var socketAddress = address.ip6SockAddr
            error = inet_ntop(Int32(socketAddress.sin6_family), &socketAddress.sin6_addr, UnsafeMutablePointer<Int8>(result), UInt32(addressStringLength))
        }
        if error != nil {
            break
        } else {
            if errno == ENOSPC {
                addressStringLength *= 2
                continue
            } else {
                return ""
            }
        }
    }
    
    return String.fromCString(UnsafePointer<CChar>(result))!
}
