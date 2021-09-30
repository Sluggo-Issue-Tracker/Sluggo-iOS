//
//  ContentView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 7/5/21.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var identity: AppIdentity
    
    @State var showLoginModal: Bool = false
    @State var showTeamsModal: Bool = false
    
    var body: some View {
        Text("Sluggo iOS")
            .padding()
            .task {
                await didAppear()
            }.sheet(isPresented: $showLoginModal) {
                } content: {
                    LoginView(showModal: $showLoginModal)
                        .interactiveDismissDisabled(true)
//            }.sheet(isPresented: $showTeamsModal) {
//                Task.init(priority: .background) {
//                    await tryTeam()
//                }
//            } content: {
//                TeamsChoiceView(showModal: $showTeamsModal)
//                    .interactiveDismissDisabled(true)
//            }
        }
    }
    
    private func didAppear() async {
        let remember = (self.identity.token != nil)
        let userManager = UserManager(identity: self.identity)

        if remember {
            let loginResult = await userManager.getUser()
            
            switch loginResult {
                case .success( _):
                    await tryTeam()
                
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.sync {
                        self.showLogin()
                    }
            }
        } else {
            self.showLogin()
        }
    }
    
    private func tryTeam() async {
        print("In tryTeam")
        if let team = identity.team {
            let teamManager = TeamManager(identity: self.identity)
            let teamResult = await teamManager.getTeam(team: team)
            switch teamResult {
            case .success(let teamRecord):
                self.identity.team = teamRecord
                DispatchQueue.main.sync {
                    self.continueLogin()
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.sync {
                    self.showLogin()
                }
            }
        } else {
            DispatchQueue.main.sync {
                self.showLogin()
            }
        }
    }
    
    private func showLogin() {
        print("In showLogin")
        self.showLoginModal.toggle()
    }

    func continueLogin() {
        print("In continueLogin")
        
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
