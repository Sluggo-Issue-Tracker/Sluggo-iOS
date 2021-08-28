//
//  LoginView.swift
//  LoginView
//
//  Created by Andrew Gavgavian on 8/27/21.
//

import SwiftUI

struct LoginView: View {
    @Binding var showModal: Bool
    @State var username: String = ""
    @State var password: String = ""
    @State var instanceURL: String = ""
    @State var isPersistance: Bool = false
    @EnvironmentObject var identity: AppIdentity
    @State var showingError: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Login Page")
                .padding()
                .font(.largeTitle)
            
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .padding()
            
            TextField("Sluggo Instance URL", text: $instanceURL)
                .textFieldStyle(.roundedBorder)
                .textContentType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            CheckBoxView(checked: $isPersistance, caption: "Remember Me?")
                .padding()
            Button("Login") {
                self.attemptLogin()
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func attemptLogin() {
        if username.isEmpty || password.isEmpty || instanceURL.isEmpty {
            // login Error
            errorMessage = "Please fill out all fields."
            showingError = true
            return
        }
            self.showModal.toggle()
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


