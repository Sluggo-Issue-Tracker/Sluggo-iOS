//
//  InviteRecord.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/31/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct UserInviteRecord: Codable, Identifiable {
    var id: Int
    var team: TeamRecord
}

struct TeamInviteRecord: Codable, Identifiable {
    var id: Int
    var userEmail: String
    var team: TeamRecord
}

struct WriteTeamInviteRecord: Codable {
    var userEmail: String
}
