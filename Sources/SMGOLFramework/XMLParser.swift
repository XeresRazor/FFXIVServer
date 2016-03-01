//
//  XMLParser.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public class Parser {
    private enum State {
        case Text
        case Tag
        case AttributeName
        case AttributeValue
        case Comment
    }
    
    private var stream: Stream
    private var node: Node
    private var text = ""
    private var attributeName = ""
    private var attributeValue = ""
    private var attributes = [AttributeType]()
    private var state: State = .Text
    private var isTagEnd = false
    private var tagSpace = false
    
    private init(stream: Stream, root: Node) {
        self.stream = stream
        self.node = root
    }
    
    private func parse() -> Bool {
        var value: Character
        do {
            value = Character(UnicodeScalar(try stream.read8()))
        } catch {
            return false
        }
        
        while !stream.isEOF() {
            var ret = false
            switch state {
            case .Text:
                ret = processCharText(value)
            case .Tag:
                ret = processCharTag(value)
            case .AttributeName:
                ret = processCharAttributeName(value)
            case .AttributeValue:
                ret = processCharAttributeValue(value)
            case .Comment:
                ret = processCharComment(value)
            }
            if ret == false {
                return false
            }
            do {
                value = Character(UnicodeScalar(try stream.read8()))
            } catch {
                return false
            }
        }
        return true
    }
    
    private func processCharText(char: Character) -> Bool {
        if char == "<" {
            // Tag is starting
            
            if text.characters.count != 0 {
                node.insertNode(Node(text: UnescapeText(text), isTag: false))
                text = ""
            }
            
            state = .Tag
            isTagEnd = false
            tagSpace = false
            return true
        }
        text.append(char)
        return true
    }
    
    private func processCharTag(char: Character) -> Bool {
        if char == "!" && text.characters.count == 0 {
            state = .Comment
            return true
        }
        
        if char == "<" {
            // ???
            return false
        }
        
        if char == "/" {
            // This is an end tag
            isTagEnd = true
            return true
        }
        
        if char == " " || char == "\t" || char == "\r" || char == "\n" {
            // Attributes follow
            state = .AttributeName
            attributeName = ""
            return true
        }
        
        if char == ">" {
            if text[text.startIndex] != "?" {
                // See if the tag name matches the current nodes name
                let hasSameName = text == node.text
                
                if isTagEnd && hasSameName {
                    // Walk up the tree
                    node = node.parent!
                } else {
                    // Create a new node
                    let child = Node(text: text, isTag: true)
                    node.insertNode(child)
                    
                    // Copy attributes
                    while attributes.count != 0 {
                        child.insertAttribute(attributes.last!)
                        attributes.removeLast()
                    }
                    
                    // Go down if it's not a singleton
                    if !isTagEnd {
                        node = child
                    }
                }
            }
            
            text = ""
            state = .Text
            return true
        }
        
        text.append(char)
        return true
    }
    
    private func processCharAttributeName(char: Character) -> Bool {
        if char == "=" {
            return true
        }
        
        if char == " " || char == "\t" || char == "\r" || char == "\n" {
            if attributeName.characters.count == 0 {
                return true
            }
            return false
        }
        
        if char == ">" || char == "/" {
            state = .Tag
            return processCharTag(char)
        }
        
        if char == "\"" {
            state = .AttributeValue
            attributeValue = ""
            return true
        }
        
        attributeName.append(char)
        return true
    }
    
    private func processCharAttributeValue(char: Character) -> Bool {
        if char == "\"" {
            attributes.append((attributeName, UnescapeText(attributeValue)))
            
            state = .AttributeName
            attributeName = ""
            return true
        }
        attributeValue.append(char)
        return true
    }
    
    private func processCharComment(char: Character) -> Bool {
        if char == ">" {
            if text[text.endIndex.advancedBy(-2) ..< text.endIndex] == "--" {
                // Comment end
                text = ""
                state = .Text
                return true
            }
        }
        text.append(char)
        return true
    }
}

public func ParseDocument(stream: Stream) -> Node? {
    let root = Node()
    
    let parser = Parser(stream: stream, root: root)
    let ret = parser.parse()
    
    if !ret {
        return nil
    }
    
    return root
}
