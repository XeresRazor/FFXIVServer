//
//  Config.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
//import PathKit

public class Config {
    typealias PreferenceMap = [String: Preference]
    
    var path: String
    var readonly: Bool
    var mutex = pthread_mutex_t()
    var preferences = PreferenceMap()
    
    public var configPath: String {
        return path
    }
    
    public init(path: String, readonly: Bool = false) {
        self.path = path
        self.readonly = readonly
        self.mutex.initialize()
        
        load()
    }
    
    deinit {
        if !readonly {
            save()
        }
    }
    
    public func makePreferenceName(level0: String, level1: String, level2: String, level3: String) -> String {
        var result = level0
        if level1.characters.count > 0 {
            result += ".\(level1)"
            if level2.characters.count > 0 {
                result += ".\(level2)"
                if level3.characters.count > 0 {
                    result += ".\(level3)"
                }
            }
        }
        return result
    }
    
    
    public func registerPreferenceInteger(name: String, value: Int) {
        guard preferences[name] == nil else {return}
        insertPreference(PreferenceInteger(name: name, value: value))
    }
    
    public func registerPreferenceBoolean(name: String, value: Bool) {
        guard preferences[name] == nil else {return}
        insertPreference(PreferenceBoolean(name: name, value: value))
    }
    
    public func registerPreferenceString(name: String, value: String) {
        guard preferences[name] == nil else {return}
        insertPreference(PreferenceString(name: name, value: value))
    }
    
    public func getPreferenceInteger(name: String) -> Int {
        guard let preference: PreferenceInteger = findPreference(name) else {
            return 0
        }
        return preference.value
    }
    
    public func getPreferenceBoolean(name: String) -> Bool {
        guard let preference: PreferenceBoolean = findPreference(name) else {
            return false
        }
        return preference.value
    }
    
    public func getPreferenceString(name: String) -> String {
        guard let preference: PreferenceString = findPreference(name) else {
            return ""
        }
        return preference.value
    }
    
    public func setPreferenceInteger(name: String, value: Int) -> Bool {
        guard readonly != true else {fatalError("Setting preference on read-only config is illegal.")}
        if let preference: PreferenceInteger = findPreference(name) {
            preference.value = value
            return true
        }
        return false
    }
    
    public func setPreferenceBoolean(name: String, value: Bool) -> Bool {
        guard readonly != true else {fatalError("Setting preference on read-only config is illegal.")}
        if let preference: PreferenceBoolean = findPreference(name) {
            preference.value = value
            return true
        }
        return false
    }
    
    public func setPreferenceString(name: String, value: String) -> Bool {
        guard readonly != true else {fatalError("Setting preference on read-only config is illegal.")}
        if let preference: PreferenceString = findPreference(name) {
            preference.value = value
            return true
        }
        return false
    }
    
    public func save() {
        if readonly {
            print("Config marked as read-only but save has been requested")
            fatalError()
        }
        
        guard let stream = CreateOutputStandardStream(path) else { return }
        
        let configNode = Node(text: "Config", isTag: true)
        for preferenceTuple in preferences {
            let preference = preferenceTuple.1
            let preferenceNode = Node(text: "Preference", isTag: true)
            preference.serialize(preferenceNode)
            configNode.insertNode(preferenceNode)
        }
        
        let document = Node()
        document.insertNode(configNode)
        Writer.writeDocument(stream, node: document)
    }
    
    func load() {
        guard let configFile = CreateInputStandardStream(String(path)) else { return }
        guard let document = ParseDocument(configFile)  else { return }
        guard let config = document.select("Config")  else { return }
        
        
        let filter = NodeFilter(node: config, filter: "Preference")
        while let pref = filter.next() {
            guard let type = pref.attribute("Type") else { continue }
            guard let name = pref.attribute("Name") else { continue }
            
            switch type {
            case "integer":
                guard let value = GetAttributeIntValue(pref, name: "Value") else { continue }
                registerPreferenceInteger(name, value: value)
            case "boolean":
                guard let value = GetAttributeBoolValue(pref, name: "Value") else { continue }
                registerPreferenceBoolean(name, value: value)
            case "string":
                guard let value = GetAttributeStringValue(pref, name: "Value") else { continue }
                registerPreferenceString(name, value: value)
            default:
                break
            }
            
        }
    }
    
    func findPreference<type: Preference>(name: String) -> type? {
        mutex.lock()
        let preference = preferences[name] as! type?
        mutex.unlock()
        return preference
    }
    
    func insertPreference(preference: Preference) {
        mutex.lock()
        preferences[preference.name] = preference
        mutex.unlock()
    }
    
    // MARK: Internal types
    internal enum PreferenceType: Int {
        case Integer
        case Boolean
        case String
    }
    
    internal class Preference {
        var name: String
        var type: PreferenceType
        
        init(name: String, type: PreferenceType) {
            self.name = name
            self.type = type
        }
        
        var typeString : String {
            switch type {
            case .Integer:
                return "integer"
            case .String:
                return "string"
            case .Boolean:
                return "boolean"
            }
        }
        
        func serialize(node: Node) {
            node.insertAttribute("Name", value: name)
            node.insertAttribute("Type", value: typeString)
        }
    }
    
    internal class PreferenceInteger: Preference {
        var value: Int
        
        init(name: String, value: Int) {
            self.value = value
            super.init(name: name, type: .Integer)
        }
        
        override func serialize(node: Node) {
            super.serialize(node)
            node.insertAttribute(CreateAttributeIntValue("Value", value: value))
        }
    }
    
    internal class PreferenceBoolean: Preference {
        var value: Bool
        
        init(name: String, value: Bool) {
            self.value = value
            super.init(name: name, type: .Boolean)
        }
        
        override func serialize(node: Node) {
            super.serialize(node)
            node.insertAttribute(CreateAttributeBoolValue("Value", value: value))
        }
    }
    
    internal class PreferenceString: Preference {
        var value: String
        
        init(name: String, value: String) {
            self.value = value
            super.init(name: name, type: .String)
        }
        
        override func serialize(node: Node) {
            super.serialize(node)
            node.insertAttribute(CreateAttributeStringValue("Value", value: value))
        }
    }
}
