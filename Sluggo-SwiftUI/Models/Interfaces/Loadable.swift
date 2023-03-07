//
//  Loadable.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 2/5/23.
//

import Foundation
enum LoadState {
    /// The download is currently in progress. This is the default.
    case loading
    
    /// The download has finished, and tickets can now be displayed.
    case success
    
    /// The download failed.
    case failed
}

protocol LoadableObject: ObservableObject {
    var loadState: LoadState { get }
    @MainActor func load() async
}
