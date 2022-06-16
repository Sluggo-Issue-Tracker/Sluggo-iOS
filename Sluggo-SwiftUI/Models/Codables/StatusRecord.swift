//
//  StatusRecord.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct StatusRecord: Codable, HasTitle, Identifiable, Equatable {
    var id: Int
    var objectUuid: UUID
    var title: String
    var color: String
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?

    func getTitle() -> String {
        return title
    }
    
    static func == (lhs: StatusRecord, rhs: StatusRecord) -> Bool {
        return lhs.objectUuid == rhs.objectUuid
    }
}
