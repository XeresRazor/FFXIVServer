//
//  Mutex.swift
//  SMGOLFramework
//
//  Created by David Green on 2/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public extension pthread_mutex_t {
    public mutating func initialize() {
        pthread_mutex_init(&self, nil)
    }
    
    public mutating func lock() {
        pthread_mutex_lock(&self)
    }
    
    public mutating func unlock() {
        pthread_mutex_unlock(&self)
    }
}
