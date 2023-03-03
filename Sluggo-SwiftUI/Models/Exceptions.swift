//
//  Exceptions.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/21/21.
//

import Foundation
import UIKit

enum RESTException: Error {
    case failedRequest(message: String)
}

enum Exception: Error {
    case runtimeError(message: String)
}

public enum LogLevel: Int{
    case debug
    case info
    case warning
    case error
}

public func track<Subject>( _ message: Subject,  _ state: LogLevel = LogLevel.debug, file: String = #file, function: String = #function, line: Int = #line) {
    track(String(describing: message), state, file: file, function: function, line: line)
}


public func track( _ message: String,  _ state: LogLevel = LogLevel.debug, file: String = #file, function: String = #function, line: Int = #line ) {
    
    // Make sure our current log level allows this
    guard state.rawValue >= Constants.Config.LOG_LEVEL.rawValue else { return }
    
    let className = file.components(separatedBy: "/").last
    var level = 0x1F7E5
    switch state {
    case .debug:
        level = 0x1F7E6
    case .info:
        level = 0x2B1C
    case .warning:
        level = 0x1F7E8
    case .error:
        level = 0x1F7E5
    }
    
    let unicodeIcon = UnicodeScalar(level)!
    print("\(unicodeIcon) \(className!):\(function):\(line): \(message)")
}
