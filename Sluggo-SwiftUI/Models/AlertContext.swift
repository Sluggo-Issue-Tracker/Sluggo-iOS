//
//  AlertContext.swift
//  AlertContext
//
//  Created by Andrew Gavgavian on 8/30/21.
//

import SwiftUI


extension View {
    func alert(context: AlertContext) -> some View {
        alert(context.alertTitle, isPresented: context.isShowingBinding) {
            Button(context.alertContinue, role: context.alertRole) { }
        } message: {
            Text(context.alertMessage)
        }
    }
}

class AlertContext: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var alertTitle: String = "Error"
    @Published var alertMessage: String = "Error message not provided"
    @Published var alertContinue: String = "OK"
    @Published var alertRole: ButtonRole = .cancel
    
    public var isShowingBinding: Binding<Bool> {
        .init(get: { self.isShowing },
              set: { self.isShowing = $0 }
        )
    }
    
    public func presentError(error: Error) -> Void {
        
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
        
        if message == "cancelled" {
            return
        }

        alertTitle = "Error"
        alertMessage = message ?? "Error message not provided"
        alertContinue = "OK"
        alertRole = .cancel
        isShowing = true
    }
}
