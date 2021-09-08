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
    
    
    @State var teamsList: [TeamRecord] = [];
    
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationView {
            List(teamsList) { team in
                Text(team.name)
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Invites") {
                        print("Invites tapped!")
                    }
                }
            }
        }
        .task {
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
        TeamsChoiceView(showModal: .constant(true))
    }
}
