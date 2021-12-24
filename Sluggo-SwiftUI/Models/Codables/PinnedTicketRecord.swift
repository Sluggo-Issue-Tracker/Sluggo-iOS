//
//  PinnedTicket.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/5/21.
//

import Foundation
// swiftlint:disable identifier_name
struct PinnedTicketRecord: Codable, Identifiable {
    let id: String // Primary key
    let objectUuid: String
    let pinned: Date
    let ticket: TicketRecord
}

struct WritePinnedTicketRecord: Codable {
    let ticket: Int
}
