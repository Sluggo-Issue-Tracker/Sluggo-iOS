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
    @State var showingError: Bool = false
    @State var errorMessage: String = ""
    var body: some Scene {
        WindowGroup {
            Group {
                LaunchView()
            }
            .environmentObject(identity)
        }
    }
}
