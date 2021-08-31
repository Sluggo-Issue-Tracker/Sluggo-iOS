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
    
    var body: some View {
        Text("Sluggo iOS")
            .padding()
            .task {
                await didAppear()
            }.sheet(isPresented: $showLoginModal) {
                Task.init(priority: .background) {
                    await tryTeam()
                }
            } content: {
                LoginView(showModal: $showLoginModal)
                    .interactiveDismissDisabled(true)
            }
    }
    
    private func didAppear() async {
        print(self.identity)
        let remember = (self.identity.token != nil)
        let userManager = UserManager(identity: self.identity)

        if remember {
            let loginResult = await userManager.getUser()
            switch loginResult {
                case .success( _):
                    // Need to also check for invalid saved team
                    await self.tryTeam()
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
            let result = await teamManager.getTeam(team: team)
            switch result {
            case .success(let teamRecord):
                self.identity.team = teamRecord
                DispatchQueue.main.sync {
                    self.continueLogin()
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.sync {
                    self.showTeams()
                }
            }
        } else {
            DispatchQueue.main.sync {
                self.showTeams()
            }
        }
    }
    
    private func showLogin() {
        print("In showLogin")
        self.showLoginModal.toggle()
    }
    
    func showTeams() {
        print("In showTeams")
    }

    func continueLogin() {
        
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
