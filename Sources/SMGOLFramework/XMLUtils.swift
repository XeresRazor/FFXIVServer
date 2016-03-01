//
//  XMLUtils.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public func GetNodeStringValue(rootNode: Node, path: String) -> String? {
    guard let node = rootNode.select(path) else { return nil }
    guard let text = node.innerText else { return nil }
    return text
}

public func GetNodeIntValue(rootNode: Node, path: String) -> Int? {
    guard let text = GetNodeStringValue(rootNode, path: path) else { return nil }
    return Int(text)
}

public func GetNodeBoolValue(rootNode: Node, path: String) -> Bool? {
    guard let text = GetNodeStringValue(rootNode, path: path) else { return nil }
    if text == "true" {
        return true
    }
    if text == "false" {
        return false
    }
    return nil
}

public func GetAttributeStringValue(node: Node, name: String) -> String? {
    guard let text = node.attribute(name) else { return nil }
    return text
}

public func GetAttributeIntValue(node: Node, name: String) -> Int? {
    guard let text = node.attribute(name) else { return nil }
    return Int(text)
}

public func GetAttributeFloatValue(node: Node, name: String) -> Float? {
    guard let text = node.attribute(name) else { return nil }
    return Float(text)
}

public func GetAttributeBoolValue(node: Node, name: String) -> Bool? {
    guard let text = node.attribute(name) else { return nil }
    if text == "true" {
        return true
    }
    if text == "false" {
        return false
    }
    return nil
}

public func CreateNodeStringValue(name: String, value: String) -> Node {
    let node = Node(text: name, isTag: true)
    node.insertNode(Node(text: value, isTag: false))
    return node
}

public func CreateNodeIntValue(name: String, value: Int) -> Node {
    let node = Node(text: name, isTag: true)
    node.insertNode(Node(text: "\(value)", isTag: false))
    return node
}

public func CreateNodeBoolValue(name: String, value: Bool) -> Node {
    let node = Node(text: name, isTag: true)
    node.insertNode(Node(text: value ? "true" : "false", isTag: false))
    return node
}

public func CreateAttributeStringValue(name: String, value: String) -> AttributeType {
    return (name, value)
}

public func CreateAttributeIntValue(name: String, value: Int) -> AttributeType {
    return (name, "\(value)")
}

public func CreateAttributeBoolValue(name: String, value: Bool) -> AttributeType {
    return (name, value ? "true" : "false")
}

func EscapeText(text: String?) -> String {
    guard let text = text else { return "" }
    var result = ""
    for charIndex in text.startIndex ..< text.endIndex {
        switch text[charIndex] {
        case "&":
            result += "&amp;"
        case "<":
            result += "&lt;"
        case ">":
            result += "&gt;"
        case "'":
            result += "&apos;"
        case "\"":
            result += "&quot;"
        default:
            result.append(text[charIndex])
        }
    }
    return result
}

func UnescapeText(text: String) -> String {
    var result = ""
    for var charIndex in text.startIndex ..< text.endIndex {
        if text[charIndex] == "&" {
            let endRange = text.rangeOfString(";")
            if let endIndex = endRange?.startIndex where endRange?.startIndex == endRange?.endIndex {
                let escapeName = text[charIndex.successor() ..< endIndex.predecessor()]
                if escapeName == "amp" {
                    result += "&"
                } else if escapeName == "lt" {
                    result += "<"
                } else if escapeName == "gt" {
                    result += ">"
                } else if escapeName == "apos" {
                    result += "'"
                } else if escapeName == "quot" {
                    result += "\""
                } else {
                    return ""
                }
                charIndex = endIndex
            } else {
                return ""
            }
        } else {
            result.append(text[charIndex])
        }
    }
    return result
}
