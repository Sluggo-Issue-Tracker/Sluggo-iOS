//
//  LoginView.swift
//  LoginView
//
//  Created by Andrew Gavgavian on 8/27/21.
//

import SwiftUI

struct LoginView: View {
    
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @Binding var showModal: Bool
    @State var showTeamsModal = false
    
    @State var username: String = ""
    @State var password: String = ""
    @State var instanceURL: String = ""
    @State var isPersistance: Bool = false
    
    
    var body: some View {
        NavigationView {
            List {
                IconSluggo()
                    .padding()
                
                Text("Login Page")
                    .padding()
                    .font(.largeTitle)
                
                LoginTextField(placeholder: "Username",
                               textValue: $username,
                               textStyle: .username)
                    .padding()
                
                LoginTextField(placeholder: "Password",
                               textValue: $password,
                               textStyle: .password,
                               isSecure: true)
                    .padding()
                
                LoginTextField(placeholder: "Sluggo Instance URL",
                               textValue: $instanceURL,
                               textStyle: .URL)
                    .padding()
                
                HStack() {
                    CheckBox(checked: $isPersistance, caption: "Remember Me?")
                        .padding()
                    
                    Spacer()
                    
                    Button("Login") {
                        self.attemptLogin()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                NavigationLink(destination: TeamsChoiceView(showLogin: $showModal), isActive: $showTeamsModal) {
                    EmptyView()
                }
                .hidden()
                .onChange(of: self.showTeamsModal, perform: closeTeams)
            }
            .alert(context: alertContext)
            .navigationBarHidden(true)
            
            
        }
    }
    
    private func closeTeams(isShowing: Bool) -> Void {
        if !isShowing && self.identity.team == nil {
            let userManager = UserManager(identity: identity)
            Task.init(priority: .background) {
                let result = await userManager.doLogout()
                
                switch result {
                case .success( _):
                    // Set identity to null
                    track("Logout!")
                    self.identity.setPersistData(persist: false)
                    self.identity.clear()
                case .failure(let error):
                    alertContext.presentError(error: error)
                }
            }
        }
    }
    
    private func attemptLogin() {
        if username.isEmpty || password.isEmpty || instanceURL.isEmpty {
            // login Error
            alertContext.presentError(error: Exception.runtimeError(message: "Please fill out all fields."))
            return
        }
        
        if !self.verifyUrl(urlString: instanceURL) {
            alertContext.presentError(error: Exception.runtimeError(
                message: "Invalid Sluggo URL, please put your entire URL."))
            return
        }
        
        Task.init(priority: .userInitiated) {
            self.identity.setPersistData(persist: isPersistance)
            self.identity.baseAddress = instanceURL
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
        let userManager = UserManager(identity: identity)
        
        let result = await userManager.doLogin(username: username, password: password)
        
        switch result {
        case .success(let record):
            // Save to identity
            self.identity.authenticatedLogin = record
            if identity.team == nil {
                self.showTeamsModal.toggle()
            }
        case .failure(let error):
            alertContext.presentError(error: error)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showModal: .constant(true))
    }
}
