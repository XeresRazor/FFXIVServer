//
//  StandardStreamUtils.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public func CreateInputStandardStream(path: String) -> StandardStream? {
    return StandardStream(path: path, options: "rb")
}

public func CreateOutputStandardStream(path: String) -> StandardStream? {
    return StandardStream(path: path, options: "wb")
}
