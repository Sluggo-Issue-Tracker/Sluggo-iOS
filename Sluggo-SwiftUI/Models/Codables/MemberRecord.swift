//
//  Member.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable
// swiftlint:disable identifier_name
struct MemberRecord: Codable, HasTitle, Identifiable, Equatable {
    var id: String
    var owner: UserRecord
    var teamId: Int
    var objectUuid: UUID
    var role: String
    @NullCodable var bio: String?
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?

    func getTitle() -> String {
        return owner.username
    }
    
    static func == (lhs: MemberRecord, rhs: MemberRecord) -> Bool {
        return lhs.objectUuid == rhs.objectUuid
    }
}
