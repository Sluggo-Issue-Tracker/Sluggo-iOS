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

extension UIAlertController {
    static func errorController(error: Error, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        // Setup message
        var message: String?
        
        if let failedRequestError = error as? RESTException {
            switch failedRequestError {
            case .failedRequest(let errMsg):
                message = errMsg
            }
        }
        
        if let exceptionError = error as? Exception {
            switch exceptionError {
            case .runtimeError(let errMsg):
                message = errMsg
            }
        }
        
        let alert = UIAlertController(title: "Error",
                                      message: message ?? "Error message not provided", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        
        return alert
    }
    
    static func errorController(error: Error) -> UIAlertController {
        return self.errorController(error: error, handler: nil)
    }
    
    static func createAndPresentError(view: UIViewController, error: Error, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController.errorController(error: error, handler: completion)
        
        view.present(alertController, animated: true, completion: nil)
    }
    
    static func createAndPresentError(view: UIViewController, error: Error) {
        UIAlertController.createAndPresentError(view: view, error: error, completion: nil)
    }
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
