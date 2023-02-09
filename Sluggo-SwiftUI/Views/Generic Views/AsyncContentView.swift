//
//  AsyncContentView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 2/5/23.
//

import Foundation
import SwiftUI


struct AsyncContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var loadingMessage: String
    var errorMessage: String
    var content: () -> Content
    
    init(source: Source,
         loadingMessage: String,
         errorMessage: String,
         @ViewBuilder content: @escaping () -> Content) {
        self.source = source
        self.loadingMessage = loadingMessage
        self.errorMessage = errorMessage
        self.content = content
    }
    
    var body: some View {
        switch source.loadState {
        case .loading:
            VStack {
                Text(loadingMessage)
                ProgressView()
            }
        case .failed:
            ErrorPage(message: errorMessage, onReload: source.load)
        case .success:
            content()
        }
    }
}
