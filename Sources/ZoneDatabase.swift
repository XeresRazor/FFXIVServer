//
//  ZoneDatabase.swift
//  FFXIVServer
//
//  Created by David Green on 2/24/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

// MARK: Types

typealias ActorVector3 = (Float32, Float32, Float32)

struct ActorDefinition {
    var id: UInt32 = 0
    var nameStringID: UInt32 = 0
    var baseModelID: UInt32 = 0
    var topModelID: UInt32 = 0
    var pos = ActorVector3(0.0, 0.0, 0.0)
}

struct ZoneDefinition {
    typealias ActorArray = [ActorDefinition]
    var backgroundMusicID: UInt32 = 0
    var battleMusicID: UInt32 = 0
    var actors = ActorArray()
}



class ZoneDatabase {
    private let zoneLocations = [
        ZoneDefLocation(zoneID: 101, name: "lanoscea"),
        ZoneDefLocation(zoneID: 102, name: "coerthas"),
        ZoneDefLocation(zoneID: 103, name: "blackshroud"),
        ZoneDefLocation(zoneID: 104, name: "thanalan"),
        ZoneDefLocation(zoneID: 105, name: "mordhona"),
        ZoneDefLocation(zoneID: 109, name: "rivenroad")
    ]

    private struct ZoneDefLocation {
        var zoneID: UInt32
        var name: String
    }
    
    private typealias ZoneDefinitionMap = [UInt32: ZoneDefinition]
    
    private var defaultZone = ZoneDefinition()
    private var zones = ZoneDefinitionMap()
    private static var zoneLocations = [ZoneDefLocation]()
    
    init() {
        defaultZone.backgroundMusicID = 0x39
        defaultZone.battleMusicID = 0x0D
    }
    
    func load() {
        let configPath = AppConfig.getBasePath()
        for zoneLocation in zoneLocations {
            let zoneDefFilename = "ffxivd_zone_\(zoneLocation.name).xml"
            let zoneDefPath = configPath + "/" + zoneDefFilename
            
            if NSFileManager.defaultManager().fileExistsAtPath(zoneDefPath) {
                guard let inputStream = CreateInputStandardStream(zoneDefPath) else { return }
                guard let zone = loadZoneDefinition(inputStream) else { return }
                zones[zoneLocation.zoneID] = zone
            } else {
                // TODO: Proper logging!
                print("File \(zoneDefPath) doesn't exist. Not loading any data for that zone.")
            }
        }
    }
    
    func getZone(zoneID: UInt32) -> ZoneDefinition? {
        guard let zone = zones[zoneID] else { return nil }
        return zone
    }
    
    func getDefaultZone() -> ZoneDefinition? {
        return defaultZone
    }
    
    func getZoneOrDefault(zoneID: UInt32) -> ZoneDefinition? {
        guard let zone = getZone(zoneID) else { return getDefaultZone() }
        return zone
    }
    
    private func loadZoneDefinition(stream: Stream) -> ZoneDefinition? {
        var result = ZoneDefinition()
        guard let documentNode = ParseDocument(stream) else { print("Cannot parse zone definition file."); return result }
        guard let zoneNode = documentNode.select("Zone") else { print("Zone definition file doesn't contain a 'Zone' node."); return result }
        
        
        if let backgroundMusicID = GetAttributeIntValue(zoneNode, name: "BackgroundMusicId") {
            result.backgroundMusicID = UInt32(backgroundMusicID)
        }
        if let battleMusicID = GetAttributeIntValue(zoneNode, name: "BattleMusicId") {
            result.battleMusicID = UInt32(battleMusicID)
        }
        
    }
}
