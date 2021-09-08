//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct TeamRecord: Codable, Equatable, Identifiable {
    var id: Int
    var name: String
    var objectUuid: UUID
    var ticketHead: Int
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?

    static func == (lhs: TeamRecord, rhs: TeamRecord) -> Bool {
        return lhs.objectUuid == rhs.objectUuid
    }

    func isMemberInTeam(memberRecord: MemberRecord?) -> Bool {
        guard let memberInfo = memberRecord else {
            return false
        }

        return self.id == memberInfo.teamId
    }
}
