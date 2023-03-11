//
//  NilContext.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 2/11/23.
//

import Foundation
import SwiftUI


struct NilContext<T, Content: View>: View {
    
    let item: T
    
    let content: () -> Content
    let nilContent: () -> Content?
    
    init(item: T, @ViewBuilder content: @escaping () -> Content, @ViewBuilder nilContent: @escaping () -> Content? = { nil }) {
        self.item = item
        self.content = content
        self.nilContent = nilContent
    }
    
    var body: some View {
        
        if(check()) {
            if(nilContent() == nil) {
                Text("None")
                    .foregroundColor(.gray)
            } else {
                nilContent()
            }
        }
        else {
            content()
        }
    }
    
    func check() -> Bool{
        let mirror = Mirror(reflecting: item)
        let style = mirror.displayStyle
        track(style)
        switch style {
        case .optional, .collection:
            return mirror.children.count == 0
        default:
            // If it's not an optional or an array
            track("In DEFAULT")
            return false
        }
    }
}
