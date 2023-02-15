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

protocol isNil {
    func isNil() -> Bool
}

//extension Optional: isNil {
//    func isNil() {
//        self.is
//    }
//}

//extension Optional: BooleanType {
//    public var boolValue: Bool {
//        switch self {
//        case .None:
//            return false
//        case .Some(let wrapped):
//            if let booleanable = wrapped as? BooleanType {
//                return booleanable.boolValue
//            }
//            return true
//        }
//    }
//}
//
//extension Array: BooleanType {
//    public var boolValue: Bool {
//        return !self.isEmpty
//    }
//}
