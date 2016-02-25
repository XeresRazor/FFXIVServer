//
//  AppearanceDatabase.swift
//  FFXIVServer
//
//  Created by David Green on 2/24/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import SMGOLFramework

struct AppearanceDefinition {
    typealias AttributeMap = [String: UInt32]
    var attributes = AttributeMap()
}

class AppearanceDatabase {
    typealias AppearanceMap = [UInt32: AppearanceDefinition]
    var appearances = AppearanceMap()
    
    static func createFromXML(stream: Stream) -> AppearanceDatabase? {
        let result = AppearanceDatabase()
        guard let documentNode = ParseDocument(stream) else { return nil }
        let appearanceNodes = documentNode.selectNodes("Appearances/Appearance")
        for appearanceNode in appearanceNodes {
            var appearance = AppearanceDefinition()
            guard let itemID = GetAttributeIntValue(appearanceNode, name:"ItemID") else { return nil }
            for appearanceAttribute in appearanceNode.attributes {
                guard appearanceAttribute.0 == "ItemId" else { continue }
                guard let attributeValue = UInt32(appearanceAttribute.1) else { return nil }
                appearance.attributes[appearanceAttribute.0] = attributeValue
            }
            result.appearances[UInt32(itemID)] = appearance
        }
        return result
    }
    
    func getAppearanceForItemID(itemID: UInt32) -> AppearanceDefinition? {
        guard let appearance = appearances[itemID] else { return nil }
        return appearance
    }
}
