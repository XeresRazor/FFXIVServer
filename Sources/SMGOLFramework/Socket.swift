//
//  Socket.swift
//  SMGOLFramework
//
//  Created by David Green on 2/25/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

func sockaddr_cast(p: UnsafePointer<sockaddr_in>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

func sockaddr_cast(p: UnsafePointer<sockaddr_in6>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

public class Socket {
    public enum SocketError: ErrorType {
        case BindError
        case OptionError
        case ListenError
    }
    
    var socketHandle: Int32
    var domain: SocketDomain
    var type: SocketType
    var address: SocketAddress? = nil
    
    public init?(domain: SocketDomain, type: SocketType) {
        self.domain = domain
        self.type = type
        socketHandle = socket(domain.value(), type.value(), 0)
        if socketHandle == -1 {
            return nil
        }
    }
    
    init(socketHandle: Int32, domain: SocketDomain, type: SocketType) {
        self.domain = domain
        self.type = type
        self.socketHandle = socketHandle
    }
    
    deinit {
        self.closeSocket()
    }
    
    public func bindTo(address: SocketAddress) throws {
        self.address = address
        var sockAddr: UnsafeMutablePointer<sockaddr>
        var sockLen: socklen_t
        var ip4Addr = address.ip4SockAddr
        var ip6Addr = address.ip6SockAddr
        
        switch address.type {
        case .ipv4:
            sockAddr = sockaddr_cast(&ip4Addr)
            sockLen = socklen_t(sizeof(sockaddr_in))
        case .ipv6:
            sockAddr = sockaddr_cast(&ip6Addr)
            sockLen = socklen_t(sizeof(sockaddr_in6))
        }
        
        guard bind(socketHandle, sockAddr , sockLen) == 0 else {
            throw SocketError.BindError
        }
    }
    
    public func closeSocket() {
        close(socketHandle)
    }
}

public extension Socket {
    public enum SocketDomain {
        case Unix
        case IPv4
        case IPv6
        
        func value() -> Int32 {
            switch self {
            case Unix:
                return AF_UNIX
            case IPv4:
                return AF_INET
            case IPv6:
                return AF_INET6
            }
        }
    }
}

extension Socket {
    public enum SocketType {
        case Stream
        case Datagram
        case SequencedPacket
        case Raw
        case ReliableDatagram
        
        func value() -> Int32 {
            switch self {
            case .Stream:
                return SOCK_STREAM
            case .Datagram:
                return SOCK_DGRAM
            case .SequencedPacket:
                return SOCK_SEQPACKET
            case Raw:
                return SOCK_RAW
            case .ReliableDatagram:
                return SOCK_RDM
            }
        }
    }
}

public extension Socket {
    public struct SocketAddress {
        public enum SocketType {
            case ipv4
            case ipv6
        }
        public typealias IP6Address = (UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)
        var ip4SockAddr = sockaddr_in()
        var ip6SockAddr = sockaddr_in6()
        var type: SocketType
        
        public init(type: SocketType, port: UInt16) {
            switch type {
            case .ipv4:
                self.init(address: 0, port: port)
            case .ipv6:
                self.init(address: in6addr_any, port: port)
            }
            self.type = type
        }
        
        public init(address: UInt32, port: UInt16) {
            type = .ipv4
            ip4SockAddr.sin_family = UInt8(AF_INET)
            ip4SockAddr.sin_addr.s_addr = address.bigEndian
            ip4SockAddr.sin_port = port.bigEndian
        }
        
        public init(address: IP6Address, port: UInt16) {
            type = .ipv6
            ip6SockAddr.sin6_family = UInt8(AF_INET6)
            ip6SockAddr.sin6_addr = in6_addr(__u6_addr: in6_addr.__Unnamed_union___u6_addr(__u6_addr16: address))
            ip6SockAddr.sin6_port = port.bigEndian
        }
        
        public init(address: in6_addr, port: UInt16) {
            type = .ipv6
            ip6SockAddr.sin6_family = UInt8(AF_INET6)
            ip6SockAddr.sin6_addr = address
            ip6SockAddr.sin6_port = port.bigEndian
        }
        
        init(sockv4: sockaddr_in) {
            type = .ipv4
            ip4SockAddr = sockv4
        }
        
        init(sockv6: sockaddr_in6) {
            type = .ipv6
            ip6SockAddr = sockv6
        }
    }
}

// TODO: implement the other options, or at least the useful ones
public extension Socket {
    public enum SocketOption {
        case AcceptConnections(Bool)
        case ReuseAddress(Bool)
    }
    
    public func setOption(option: SocketOption) throws {
        var optVal = UnsafePointer<Void>()
        var optLen: UInt32
        var optName: Int32
        var optLevel: Int32
        
        var int32Val = Int32(0)
        //var stringVal = ""
        
        switch option {
        case .AcceptConnections(let value):
            int32Val = value ? 1 : 0
            withUnsafePointer(&int32Val){
                optVal = UnsafePointer($0)
            }
            optLen = UInt32(sizeof(Int32))
            optName = SO_ACCEPTCONN
            optLevel = SOL_SOCKET
        case .ReuseAddress(let value):
            int32Val = value ? 1 : 0
            withUnsafePointer(&int32Val){
                optVal = UnsafePointer($0)
            }
            optLen = UInt32(sizeof(Int32))
            optName = SO_REUSEADDR
            optLevel = SOL_SOCKET
        }
        
        guard setsockopt(socketHandle, optLevel, optName, optVal, optLen) == 0 else { throw SocketError.OptionError }
    }
}

public extension Socket {
    public typealias ListeningHandler = () -> Void
    public typealias ConnectionAcceptedHandler = (socket: Socket, address: SocketAddress) -> Void
    
    public func beginListening(backlog: Int32 = SOMAXCONN, listeningHandler: ListeningHandler, connectionHandler: ConnectionAcceptedHandler) throws {
        guard listen(socketHandle, backlog) == 0 else { throw SocketError.ListenError }
        
        guard let selfAddress = self.address else { throw SocketError.ListenError }
        listeningHandler()
        
        while true {
            var address: SocketAddress
            var socket: Socket
            switch selfAddress.type {
            case .ipv4:
                var incomingAddress = sockaddr_in()
                var incomingAddressSize = socklen_t(sizeof(sockaddr_in))
                let incomingSocket = accept(self.socketHandle, sockaddr_cast(&incomingAddress), &incomingAddressSize)
                address = SocketAddress(sockv4: incomingAddress)
                socket = Socket(socketHandle: incomingSocket, domain: self.domain, type: self.type)
            case .ipv6:
                var incomingAddress = sockaddr_in6()
                var incomingAddressSize = socklen_t(sizeof(sockaddr_in6))
                let incomingSocket = accept(self.socketHandle, sockaddr_cast(&incomingAddress), &incomingAddressSize)
                address = SocketAddress(sockv6: incomingAddress)
                socket = Socket(socketHandle: incomingSocket, domain: self.domain, type: self.type)
            }
            connectionHandler(socket: socket, address: address)
        }
    }
}

public extension Socket {
    public func setNonBlocking(shouldBlock:Bool) {
        var flags = fcntl(socketHandle, F_GETFL, 0)
        if shouldBlock {
            flags &= ~O_NONBLOCK
        } else {
            flags |= O_NONBLOCK
        }
        _ = fcntl(socketHandle, F_SETFL, flags)
    }
    
}
