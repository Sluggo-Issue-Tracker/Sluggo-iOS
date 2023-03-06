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
    
    @StateObject private var viewModel = ViewModel()
    
//    Incoming binding from Home View
    @Binding var showModal: Bool
    
    
    var body: some View {
        NavigationStack {
            List {
                IconSluggo()
                    .padding()
                
                Text("Login Page")
                    .padding()
                    .font(.largeTitle)
                
                LoginTextField(placeholder: "Username",
                               textValue: $viewModel.username,
                               textStyle: .username)
                    .padding()
                
                LoginTextField(placeholder: "Password",
                               textValue: $viewModel.password,
                               textStyle: .password,
                               isSecure: true)
                    .padding()
                
                LoginTextField(placeholder: "Sluggo Instance URL",
                               textValue: $viewModel.instanceURL,
                               textStyle: .URL)
                    .padding()
                
                HStack() {
                    CheckBox(checked: $viewModel.isPersistance, caption: "Remember Me?")
                        .padding()
                    
                    Spacer()
                    
                    Button("Login") {
                        self.viewModel.attemptLogin()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .navigationDestination(isPresented: $viewModel.showTeamsModal){
                TeamsChoiceView(showLogin: $showModal)
            }
            .onChange(of: self.viewModel.showTeamsModal) {
                self.viewModel.closeTeams(isShowing: $0)
            }
            .alert(context: alertContext)
            .navigationBarHidden(true)
            
            
        }
        .task {
            viewModel.setup(identity: identity, alertContext: alertContext)
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showModal: .constant(true))
    }
}
