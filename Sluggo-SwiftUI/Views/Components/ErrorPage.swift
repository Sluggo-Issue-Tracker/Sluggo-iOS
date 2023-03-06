//
//  ErrorPage.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 6/16/22.
//

import Foundation
import SwiftUI

struct ErrorPage: View {
    var message: String
    var onReload: @MainActor () async  -> Void
    var body: some View {
        VStack {
            Text(message)
            Button{
                // When the user attempts to retry, immediately switch back to
                // the loading state.
                Task {
                    // Important: wait 0.5 seconds before retrying the download, to
                    // avoid jumping straight back to .failed in case there are
                    // internet problems.
                    try await Task.sleep(nanoseconds: 500_000_000)
                    await onReload()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("Retry")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(40)
            }
        }
    }
}
