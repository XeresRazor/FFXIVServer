//
//  main.swift
//  FFXIVServer
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif



//let config = Config(path: "/Users/dagre/Library/Mobile Documents/com~apple~CloudDocs/Projects/OpenSource/SeventhUmbral/daemon/config.xml", readonly: true)
//let value = config.getPreferenceString("ffxivd.database.username")
//print("Database username: \(value)")

// Main

if !AppConfig.instance().isConfigAvailable() {
    let configPath = AppConfig.getBasePath()
    // TODO: replace this with a proper logging system
    print("Config file not available. Make sure there is a 'config.xml' file in '\(configPath)'.")
}
// Config is loaded, let's fire her up
let serverAddress = AppConfig.instance().getPreferenceString("ffxivd.gameserver.address")
print("Starting server at address: \(serverAddress)")

GlobalData.instance().prepare()
