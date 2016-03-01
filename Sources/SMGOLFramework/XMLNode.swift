//
//  XMLNode.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

/// Description: XML Node object

import Foundation

public typealias AttributeType = (String, String)

public class Node {
    public typealias NodeList = [Node]
    public typealias AttributeList = [String: String]
    
    public var text: String?
    public var parent: Node?
    public var isTag: Bool = false
    private(set) public var children: NodeList = NodeList()
    private(set) public var attributes: AttributeList = AttributeList()
    
    public var innerText: String? {
        if children.count != 1 {
            return nil
        }
        return children.first!.text
    }
    
    public convenience init(text: String, isTag: Bool) {
        self.init()
        self.text = text
        self.isTag = isTag
    }
    
    public func insertNode(node: Node) -> Node {
        assert(node.parent == nil)
        node.parent = self
        children.append(node)
        return node
    }
    
    public func insertTextNode(text: String) -> Node {
        return insertNode(Node(text: text, isTag: false))
    }
    
    public func insertTagNode(name: String) -> Node {
        return insertNode(Node(text: name, isTag: true))
    }
    
    public func insertNode(node: Node, atIndex index: Int) {
        assert( node.parent == nil)
        node.parent = self
        children.insert(node, atIndex: index)
    }
    
    public func insertAttribute(attribute: AttributeType) -> Node {
        attributes[attribute.0] = attribute.1
        return self
    }
    
    public func insertAttribute(name: String, value: String) -> Node {
        return insertAttribute((name, value))
    }
    
    public func childCount() -> Int {
        return children.count
    }
    
    public func firstChild() -> Node {
        assert(!children.isEmpty)
        return children.first!
    }
    
    public func removeChildAt(index: Int) {
        children.removeAtIndex(index)
    }
    
    public func attribute(name: String) -> String? {
        return attributes[name]
    }
    
    public func attributeCount() -> Int {
        return attributes.count
    }
    
    public func searchForNode(named name: String) -> Node? {
        for node in children {
            if !node.isTag {
                continue
            }
            
            if node.text == name {
                return node
            }
        }
        return nil
    }
    
    private func selectNodesImplementation(path: String, single: Bool) -> NodeList {
        var node: Node? = self
        var curr = path
        
        while true {
            // check if we're at the end of an expression
            let range = curr.rangeOfString("/")
            guard range != nil else { break /* We are */ }
            let position = range!.startIndex
            let next = curr[curr.startIndex ..< position]
            
            node = node?.searchForNode(named: next)
            
            if node == nil {
                return NodeList()
            }
            
            curr = curr[position.successor() ..< curr.endIndex]
        }
        
        var tempList = NodeList()
        
        let filter = NodeFilter(node: node!, filter: curr)
        while let filteredNode = filter.next() {
            tempList.append(filteredNode)
            if single { break }
        }
        
        return tempList
    }
    
    public func select(path: String) -> Node? {
        return selectNodesImplementation(path, single: true).first
    }
    
    public func selectNodes(path: String) -> NodeList {
        return selectNodesImplementation(path, single: false)
    }
}
