//
//  TeamsChoiceView.swift
//  TeamsChoiceView
//
//  Created by Andrew Gavgavian on 8/30/21.
//

import SwiftUI

struct TeamsChoiceView: View {
    
    @EnvironmentObject var identity: AppIdentity
    
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationView {
            List() {
                
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
    }
}

struct TeamsChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsChoiceView(showModal: .constant(true))
    }
}
