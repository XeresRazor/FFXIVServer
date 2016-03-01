//
//  XMLNodeFilter.swift
//  SMGOLFramework
//
//  Created by David Green on 2/23/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

class NodeFilter {
    let node: Node
    let filter: String
    var index = 0
    
    init(node: Node, filter: String) {
        self.node = node
        self.filter = filter
    }
    
    func next() -> Node? {
        while index < node.childCount() {
            let node = self.node.children[index]
            index += 1
            if !node.isTag {
                continue
            }
            if node.text == filter {
                return node
            }
        }
        return nil
    }
}
