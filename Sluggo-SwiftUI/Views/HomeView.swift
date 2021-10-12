//
//  HomeView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 9/29/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    var body: some View {
        TabView {
            
            Text("Welcome Home \(identity.authenticatedUser!.username)" )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            Text("Ticket List Here")
                .tabItem {
                    Image(systemName: "ticket.fill")
                    Text("Tickets")
                }
            Text("Member List and Settings Here")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Members")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
