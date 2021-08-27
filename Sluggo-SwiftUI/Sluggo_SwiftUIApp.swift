//
//  Sluggo_SwiftUIApp.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 7/5/21.
//

import SwiftUI

@main
struct Sluggo_SwiftUIApp: App {
    
    var identity: AppIdentity = AppIdentity.loadFromDisk() ?? AppIdentity()
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
