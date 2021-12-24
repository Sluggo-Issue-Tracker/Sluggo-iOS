//
//  TagRecord.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct TagRecord: Codable, HasTitle, Identifiable {
    var id: Int
    var teamId: Int
    var objectUuid: UUID
    var title: String
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?

    func getTitle() -> String {
        return title
    }
}

struct WriteTagRecord: Codable {
    var title: String
}
