//
//  Log.swift
//  FFXIVServer
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

class Log {
    private static let Instance = Log()
    
    static func instance() -> Log {
        return Instance
    }
    
    init() {
        #if os(Linux)
            openlog("ffxivserver", LOG_PID | LOG_NDELAY, LOG_USER)
        #endif
    }
    
    deinit {
        #if os(Linux)
            closelog()
        #endif
    }
    
    func logDebug(serviceName: String, message: String) {
        let logMessage = "[Debug] \(serviceName): \(message)"
        writeToLog(logMessage)
    }
    func logMessage(serviceName: String, message: String) {
        let logMessage = "[Message] \(serviceName): \(message)"
        writeToLog(logMessage)
    }
    func logError(serviceName: String, message: String) {
        let logMessage = "[Error] \(serviceName): \(message)"
        writeToLog(logMessage)
    }
    
    func writeToLog(message: String) {
        #if os(Linux)
            vsyslog(LOG_NOTICE, "%s", message)
        #else
            print(message)
            // TODO: Log to file?
        #endif
    }
}