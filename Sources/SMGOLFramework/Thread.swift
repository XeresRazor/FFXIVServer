//
//  Thread.swift
//  SMGOLFramework
//
//  Created by David Green on 2/25/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

func threadMain(x: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
    let closure = UnsafeMutablePointer<(Void) -> Void>(x)
    closure.memory()
    return nil
}

public class Thread {
    static var threads = [pthread_t: Thread]()
    
    public static func thisThread() -> Thread? {
        print("Thread: \(threads)")
        let threadID = pthread_self()
        guard let thread = threads[threadID] else { return nil }
        return thread
    }
    
    var mainClosure: () -> Void
    var thread = pthread_t()
    
    public init(closure:() -> Void) {
        mainClosure = closure
        
    }
    
    
    
    public func start() {
        var threadAttributes = pthread_attr_t()
        guard pthread_attr_init(&threadAttributes) == 0 else { print("Failed to initialize thread."); return }
        guard pthread_create(&thread, &threadAttributes, threadMain, &mainClosure) == 0 else { print("Failed to start thread."); return }
        print("Started thread: \(thread)")
        Thread.threads[thread] = self
    }
    
    public func stop() {
        pthread_exit(nil)
    }
    
    public func detach(){
        pthread_detach(thread)
    }
    
    public func join() {
        pthread_join(thread, nil)
    }
}