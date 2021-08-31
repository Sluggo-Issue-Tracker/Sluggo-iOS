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
    
    @State var username: String = ""
    @State var password: String = ""
    @State var instanceURL: String = ""
    @State var isPersistance: Bool = false
    
    
    var body: some View {
        Spacer()
        
        Form {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .scaledToFit()
            
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
                CheckBoxView(checked: $isPersistance, caption: "Remember Me?")
                    .padding()
                
                Spacer()
                
                Button("Login") {
                    self.attemptLogin()
                }
                .buttonStyle(.borderedProminent)
            }
            
            
        }
        .alert(context: alertContext)
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
            self.identity.baseAddress = instanceURL
            self.identity.setPersistData(persist: isPersistance)
            await self.attemptLogin(username: username, password: password)
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
    private func attemptLogin(username: String, password: String) async {
        let userManager = UserManager(identity: identity)
        
        let result = await userManager.doLogin(username: username, password: password)
        
        switch result {
        case .success(let record):
            // Save to identity
            self.identity.authenticatedLogin = record
            self.showModal.toggle()
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

struct CheckBoxView: View {
    @Binding var checked: Bool
    var caption: String
    
    var body: some View {
        HStack {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
                .onTapGesture {
                    self.checked.toggle()
                }
            
            Text(caption)
                .font(.caption)
                .fontWeight(.regular)
        }
    }
}



struct LoginTextField: View {
    @State var placeholder: String
    @Binding var textValue: String
    @State var textStyle: UITextContentType
    var isSecure: Bool = false
    var body: some View {
        if isSecure == true {
            SecureField(placeholder, text: $textValue)
                .textContentType(textStyle)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        } else {
            TextField(placeholder, text: $textValue)
                .textContentType(textStyle)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        
    }
}
