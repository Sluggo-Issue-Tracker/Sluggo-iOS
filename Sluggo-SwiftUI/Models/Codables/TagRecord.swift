//
//  TagRecord.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
extension Hashable where Self: Any {

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
    }
}


struct TagRecord: Codable, HasTitle, Identifiable, Equatable, Hashable {
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.objectUuid == rhs.objectUuid
    }
}

struct WriteTagRecord: Codable {
    var title: String
}
