//
//  TicketRecord.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//  Edited by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable
// swiftlint:disable identifier_name
struct TicketRecord: Codable, Identifiable, Equatable {
    var id: Int
    var ticketNumber: Int
    var tagList: [TagRecord]
    var objectUuid: UUID
    @NullCodable var assignedUser: MemberRecord?
    @NullCodable var status: StatusRecord?
    var title: String
    @NullCodable var description: String?
    // var comments?  Future Future Implementation
    @NullCodable var dueDate: Date?
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.objectUuid == rhs.objectUuid
    }
    
}

struct WriteTicketRecord: Codable {
    var tagList: [Int]
    @NullCodable var assignedUser: String?
    @NullCodable var status: Int?
    var title: String
    @NullCodable var description: String?
    @NullCodable var dueDate: Date?
}
