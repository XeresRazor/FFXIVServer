//
//  GlobalData.swift
//  FFXIVServer
//
//  Created by David Green on 2/24/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

class GlobalData {
    // MARK: Singleton Instance methods
    private static let Instance = GlobalData()
    
    static func instance() -> GlobalData {
        return Instance
    }
    
    // MARK: Class instance methods
    private(set) var zoneDatabase = ZoneDatabase()
    private(set) var weaponAppearanceDatabase: AppearanceDatabase? = nil
    
    init() {}
    
    func prepare() {
        zoneDatabase.load()
        loadWeaponAppearanceDatabase()
    }
    
    func loadWeaponAppearanceDatabase() {
        let configPath = AppConfig.getBasePath()
        let weaponAppearanceDatabasePath = configPath + "/" + "ffxivd_weapon_appearances.xml"
        if NSFileManager.defaultManager().fileExistsAtPath(weaponAppearanceDatabasePath) {
            guard let inputStream = CreateInputStandardStream(weaponAppearanceDatabasePath) else { return }
            weaponAppearanceDatabase = AppearanceDatabase.createFromXML(inputStream)
        } else {
            // TODO: Add actual logging
            print("File \(weaponAppearanceDatabasePath) doesn't exist. Not loading any weapon appearance data.")
        }
    }
}
