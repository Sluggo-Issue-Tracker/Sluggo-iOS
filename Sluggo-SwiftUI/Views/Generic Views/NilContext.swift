//
//  NilContext.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 2/11/23.
//

import Foundation
import SwiftUI


struct NilContext<T, Content: View>: View {
    
    var item: T
    
    
    @ViewBuilder var content: Content
    
    var body: some View {
        
        if(check()) {
            Text("None").foregroundColor(.gray)
        }
        else {
            content
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
