//
//  PinnedTicketManager.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/5/21.
//

import Foundation
import CryptoKit

class PinnedTicketManager {
    static let urlBase = "/pinned_tickets/"
    private var identity: AppIdentity
    private var member: MemberRecord
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, member: MemberRecord, requestLoader: CanNetworkRequest = JsonLoader()) {
        self.identity = identity
        self.member = member
        self.requestLoader = requestLoader
    }

    private func makeListURL() -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase + String(identity.team!.id) +
            MemberManager.urlBase + member.id + PinnedTicketManager.urlBase
        return URL(string: urlString)!
    }

    private func makeDetailURL(desiredID: String) -> URL {
        return URL(string: makeListURL().absoluteString + "\(desiredID)/")!
    }

    public func fetchPinnedTickets() async -> Result<[PinnedTicketRecord], Error> {
        let requestBuilder = URLRequestBuilder(url: makeListURL())
            .setMethod(method: .GET)
            .setIdentity(identity: identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func postPinnedTicket(ticket: TicketRecord) async -> Result<PinnedTicketRecord, Error> {

        let writeRecord = WritePinnedTicketRecord(ticket: ticket.id)

        guard let body = type(of: requestLoader).encode(object: writeRecord) else {
            let errorMessage = "Failed to serialize write pinned ticket record in PinnedTicketManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: makeListURL())
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func deletePinnedTicket(pinned: PinnedTicketRecord) async -> Result<Void, Error> {

        let requestBuilder = URLRequestBuilder(url: makeDetailURL(desiredID: pinned.id))
            .setMethod(method: .DELETE)
            .setIdentity(identity: identity)

        return await requestLoader.executeEmptyRequest(request: requestBuilder.getRequest())
    }

    public func fetchPinned(ticket: TicketRecord) async -> Result<PinnedTicketRecord, Error> {

        // MARK: MD5 hashing convenience
        func MD5String(for str: String) -> String {
            let digest = Insecure.MD5.hash(data: str.data(using: .utf8)!)

            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        }

        // Calculate the member PK
        let memberHash = MD5String(for: String(member.id))
        let ticketHash = MD5String(for: String(ticket.id))

        let pinnedID = memberHash.appending(ticketHash)
        let requestBuilder = URLRequestBuilder(url: makeDetailURL(desiredID: pinnedID))
            .setMethod(method: .GET)
            .setIdentity(identity: identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }
}
