//
//  LoginViewModel.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 2/8/23.
//

import Foundation
import SwiftUI


extension LoginView {
    
    class ViewModel: ObservableObject {
        
        var identity: AppIdentity?
        var alertContext: AlertContext?
        
        @Published var showTeamsModal = false
        
        @Published var username: String = ""
        @Published var password: String = ""
        @Published var instanceURL: String = ""
        @Published var isPersistance: Bool = false
        
        
        
        func setup(identity: AppIdentity, alertContext: AlertContext) {
            self.identity = identity
            self.alertContext = alertContext
        }
        @MainActor
        func closeTeams(isShowing: Bool) -> Void {
            if !isShowing && self.identity!.team == nil {
                let userManager = UserManager(identity: identity!)
                Task.init(priority: .background) {
                    let result = await userManager.doLogout()
                    
                    switch result {
                    case .success( _):
                        // Set identity to null
                        track("Logout!")
                        self.identity!.setPersistData(persist: false)
                        self.identity!.clear()
                    case .failure(let error):
                        alertContext?.presentError(error: error)
                    }
                }
            }
        }
        @MainActor
        func attemptLogin() {
            if username.isEmpty || password.isEmpty || instanceURL.isEmpty {
                // login Error
                alertContext?.presentError(error: Exception.runtimeError(message: "Please fill out all fields."))
                return
            }
            
            if !self.verifyUrl(urlString: instanceURL) {
                alertContext?.presentError(error: Exception.runtimeError(
                    message: "Invalid Sluggo URL, please put your entire URL."))
                return
            }
            
            Task.init(priority: .userInitiated) {
                self.identity!.setPersistData(persist: isPersistance)
                self.identity!.baseAddress = instanceURL
                await self.performLogin(username: username, password: password)
            }
        }
        
        private func verifyUrl (urlString: String?) -> Bool {
            if let urlString = urlString {
                if let url = NSURL(string: urlString) {
                    return UIApplication.shared.canOpenURL(url as URL)
                }
            }
            return false
        }
        
        @MainActor
        private func performLogin(username: String, password: String) async {
            let userManager = UserManager(identity: identity!)
            
            let result = await userManager.doLogin(username: username, password: password)
            
            switch result {
            case .success(let record):
                // Save to identity
                self.identity!.authenticatedLogin = record
                if identity!.team == nil {
                    self.showTeamsModal.toggle()
                }
            case .failure(let error):
                alertContext?.presentError(error: error)
            }
        }
    }
}
