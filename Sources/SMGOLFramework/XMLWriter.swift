//
//  XMLWriter.swift
//  SMGOLFramework
//
//  Created by David Green on 2/23/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public class Writer {
    var stream: Stream
    
    init(stream: Stream) {
        self.stream = stream
    }
    
    public class func writeDocument(stream: Stream, node: Node) {
        let writer = Writer(stream: stream)
        writer.writeNode(node, level:0)
    }
    
    private func writeNode(currentnode: Node, level: UInt) {
        if currentnode.text == "" {
            if currentnode.childCount() == 1 {
                writeNode(currentnode.firstChild(), level: level)
                return
            }
        }
        
        if currentnode.childCount() == 0 {
            if currentnode.isTag {
                dumpTabs(level)
                dumpString("<")
                dumpString(currentnode.text)
                dumpAttributes(currentnode)
                dumpString(" />\r\n")
            }
            return
        }
        
        if currentnode.childCount() == 1 {
            if !currentnode.firstChild().isTag {
                dumpTabs(level)
                
                dumpString("<")
                dumpString(currentnode.text)
                dumpAttributes(currentnode)
                dumpString(">")
                
                dumpString(EscapeText(currentnode.innerText))
                
                dumpString("</")
                dumpString(currentnode.text)
                dumpString(">\r\n")
                
                return
            }
        }
        
        dumpTabs(level)
        dumpString("<")
        dumpString(currentnode.text)
        dumpAttributes(currentnode)
        dumpString(">\r\n")
        
        for node in currentnode.children {
            writeNode(node, level: level + 1)
        }
        
        dumpTabs(level)
        dumpString("</")
        dumpString(currentnode.text)
        dumpString(">\r\n")
    }
    
    private func dumpString(string: String?) {
        if string == nil {
            return
        }
        stream.write([UInt8](string!.utf8))
    }
    
    private func dumpTabs(count: UInt) {
        for _ in 0 ..< count {
            stream.write8([UInt8]("\t".utf8)[0])
        }
    }
    
    private func dumpAttributes(node: Node) {
        for attribute in node.attributes {
            dumpString(" ")
            dumpString(attribute.0)
            dumpString("=\"")
            dumpString(EscapeText(attribute.1))
            dumpString("\"")
        }
    }
}
