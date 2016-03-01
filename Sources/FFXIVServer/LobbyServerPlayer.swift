//
//  LobbyServerPlayer.swift
//  FFXIVServer
//
//  Created by David Green on 2/29/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

class LobbyServerPlayer {
    let socket: Socket
//    var packetQueue = [PacketData]()
    var disconnect = false
    var userID: UInt32 = ~0
    
    init(socket: Socket) {
        PacketUtils.hasPacket(MemStream())
        self.socket = socket
    }
    
    func isConnected() -> Bool {
        return !disconnect
    }
    
    func update() {
        
    }
}
