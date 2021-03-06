//
//  AppConfig.swift
//  FFXIVServer
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

let ConfigFilename = "config.xml"


class AppConfig: Config {
    // MARK: Singleton Instance methods
    private static let Instance = AppConfig()
    
    static func instance() -> AppConfig {
        return Instance
    }
    
    // MARK: Class and instance methods
    init() {
        super.init(path: self.dynamicType.buildConfigPath(), readonly: true)
    }
    
    
    static func getBasePath() -> String {
        return "/usr/local/etc/ffxivserver"
    }
    
    static func  buildConfigPath() -> String {
        return getBasePath() + "/" + ConfigFilename
    }
    
    func isConfigAvailable() -> Bool {
        let configFilePath = self.dynamicType.buildConfigPath()
        return NSFileManager.defaultManager().fileExistsAtPath(configFilePath)
    }
}