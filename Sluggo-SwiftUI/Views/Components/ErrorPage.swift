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
    var onReload: () -> Void
    var body: some View {
        VStack {
            Text(message)
            Button{
                onReload()
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
