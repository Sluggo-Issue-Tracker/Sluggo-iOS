//
//  OptionalOperator.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 3/10/23.
//

import Foundation
import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
