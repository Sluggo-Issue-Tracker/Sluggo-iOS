//
//  Sluggo_SwiftUIApp.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 7/5/21.
//

import SwiftUI

@main
struct Sluggo_SwiftUIApp: App {
    
    @StateObject var identity: AppIdentity = AppIdentity.loadFromDisk() ?? AppIdentity()
    var body: some Scene {
        WindowGroup {
            ContainerView()
            .environmentObject(identity)
        }
    }
}

struct ContainerView: View {
    @EnvironmentObject var identity: AppIdentity
    
    var body: some View {
        if identity.team == nil {
            LaunchView()
        }
        else {
            HomeView()
        }
    }
}
