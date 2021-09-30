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
    @State var isLoggedIn: Bool = false
    @State var showingError: Bool = false
    @State var errorMessage: String = ""
    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoggedIn {
                    LaunchView(showLaunch: $isLoggedIn)
                } else {
                    HomeView()
                }
            }
            .environmentObject(identity)
        }
    }
}
