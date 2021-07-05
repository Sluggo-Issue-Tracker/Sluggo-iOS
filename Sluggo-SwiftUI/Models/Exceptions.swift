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
