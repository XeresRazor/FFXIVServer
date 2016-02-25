//
//  LobbyServer.swift
//  FFXIVServer
//
//  Created by David Green on 2/25/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

func ClientThreadProcess(clientSocket: Int32, inout clientSocketAddress: sockaddr_in) -> Void {
    Log.instance().logDebug("LobbyClientThread", message: "Client connected")
}

class LobbyServer {
    let LogName = "LobbyServer"
    var thread: Thread? = nil
    
    func start() {
        let serverThread = Thread(){
            self.serverThreadProcess()
        }
        serverThread.start()
        thread = serverThread
    }
    
    func serverThreadProcess() -> Void {
        let listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        
        var reuseOptionValue: Int32 = 1
        guard setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &reuseOptionValue, UInt32(sizeof(sockaddr_in))) == 0 else {
            Log.instance().logError(LogName, message: "Unable to initialize network socket.")
            fatalError()
        }
        
        var service = sockaddr_in()
        service.sin_family = UInt8(AF_INET)
        service.sin_addr.s_addr = UInt32(0).bigEndian
        service.sin_port = UInt16(54994).bigEndian
        
        guard bind(listenSocket, sockaddr_cast(&service), socklen_t(sizeof(sockaddr_in))) == 0 else {
            Log.instance().logError(LogName, message: "Failed to bind socket.")
            return
        }
        
        guard listen(listenSocket, SOMAXCONN) == 0 else {
            Log.instance().logError(LogName, message: "Failed to listen on socket.")
            return
        }
        
        Log.instance().logMessage(LogName, message: "Lobby server started.")
        
        while true {
            var incomingAddress = sockaddr_in()
            var incomingAddressSize = socklen_t(sizeof(sockaddr_in))
            let incomingSocket = accept(listenSocket, sockaddr_cast(&incomingAddress), &incomingAddressSize)
            let clientThread = Thread() {
                ClientThreadProcess(incomingSocket, clientSocketAddress: &incomingAddress)
            }
            clientThread.start()
            clientThread.detach()
        }
    }
}
