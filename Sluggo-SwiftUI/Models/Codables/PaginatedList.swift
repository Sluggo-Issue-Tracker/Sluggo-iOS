//
//  PaginatedList.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/18/21.
//

import Foundation
import NullCodable

struct PaginatedList<T: Codable>: Codable {
    var count: Int
    @NullCodable var next: String?
    @NullCodable var previous: String?
    let results: [T]

}
