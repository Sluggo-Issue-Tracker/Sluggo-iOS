//
//  NilContext.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 1/31/23.
//

import Foundation
import SwiftUI

struct NilContext<Item, Element, Content: View>: View {
    
    var item: Item
    
    enum choose {
        case option(Element?)
        case arr([Element])
    }
    
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
        
        switch item {
        case let result where item: Optional:
            return result == nil
            
        case let result where Item: Array:
            return result.isEmpty
            
        default:
            return true
        }
        
    }
}
