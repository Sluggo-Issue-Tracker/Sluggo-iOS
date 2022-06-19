//
//  TeamsChoiceView.swift
//  TeamsChoiceView
//
//  Created by Andrew Gavgavian on 8/30/21.
//

import SwiftUI

struct TeamsChoiceView: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @Binding var showLogin: Bool
    
    @State var teamsList: [TeamRecord] = []
    
    var body: some View {
        List(teamsList) { team in
            Button(team.name) {
                self.identity.team = team
                self.showLogin.toggle()
            }
            //.buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Teams")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Invites") {
                    track("Invites tapped!")
                }
            }
        }
        .task {
            await didAppear()
        }
        .refreshable {
            await didAppear()
        }
        .alert(context: alertContext)
    }
    
    private func didAppear() async {
        let userManager = UserManager(identity: self.identity)
        let teamsResult = await userManager.getTeamsForUser()
        switch teamsResult {
            case .success(let teams):
                // Need to also check for invalid saved team
                teamsList = teams
            case .failure(let error):
                print(error)
                alertContext.presentError(error: error)
        }
    }
}

struct TeamsChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsChoiceView(showLogin: .constant(true))
    }
}
