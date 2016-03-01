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

func ClientThreadProcess(clientSocket: Socket, address: Socket.SocketAddress) -> Void {
    clientSocket.setNonBlocking(false)
    Log.instance().logMessage("LobbyClientThread", message: "Received connection from \(GetSocketIPAddressString(address)).")
    
    let player = LobbyServerPlayer(socket: clientSocket)
    
    while player.isConnected() {
        player.update()
//        print("Updating player.")
        usleep(16 * 1000)
    }
    
    clientSocket.closeSocket()
}

class LobbyServer {
    let LogName = "LobbyServer"
    var thread: Thread? = nil
    
    func start() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.serverThreadProcess()
        }
    }
    
    func serverThreadProcess() {
        guard let listenSocket = Socket(domain:.IPv4, type:.Stream) else { Log.instance().logError(LogName, message: "Unable to create a socket."); return }
        
        do {
            try listenSocket.setOption(.ReuseAddress(true))
        } catch {
            Log.instance().logError(LogName, message: "Unable to configure network socket for reuse.")
            fatalError()
        }
        
        let address = Socket.SocketAddress(type: .ipv4, port: 54994)
        do {
            try listenSocket.bindTo(address)
        } catch {
            Log.instance().logError(LogName, message: "Failed to bind socket (address/port may be in use).")
            return
        }
        
        do {
            try listenSocket.beginListening(0, listeningHandler: {
                Log.instance().logMessage(self.LogName, message: "Lobby server started.")
                }, connectionHandler:{(socket, address) in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        ClientThreadProcess(socket, address: address)
                    }
            })
        } catch {
            Log.instance().logError(LogName, message: "Failed to bind socket.")
            return
        }
    }
}
