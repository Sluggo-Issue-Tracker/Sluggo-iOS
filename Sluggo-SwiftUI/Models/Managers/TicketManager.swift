//
//  TicketManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TicketManager {
    static let urlBase = "/tickets/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
    }

    private func makeDetailUrl(_ ticketRecord: TicketRecord) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TicketManager.urlBase + "\(ticketRecord.id)/"
        return URL(string: urlString)!
    }

    public func makeListUrl(page: Int, queryParams: TicketFilterParameters) -> URL {
        var urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TicketManager.urlBase + "?page=\(page)"
        urlString += queryParams.toParamString()

        return URL(string: urlString)!
    }

    // Future: nest a params class might make querying slightly easier
    public func makeListUrl(page: Int, assignedMember: MemberRecord?) -> URL {
        let queryParams = TicketFilterParameters(assignedUser: assignedMember)

        return makeListUrl(page: page, queryParams: queryParams)
    }

    public func listTeamTickets(page: Int, queryParams: TicketFilterParameters) async -> Result<PaginatedList<TicketRecord>, Error>  {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page, queryParams: queryParams))
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func makeTicket(ticket: WriteTicketRecord) async -> Result<TicketRecord, Error> {
        guard let body = BaseLoader.encode(object: ticket) else {
            let errorMessage = "Failed to serialize ticket JSON for makeTicket in TicketManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        // NOTE: this works but the page here does effectively nothing. I think for clarity introducing a separate
        // function for making the url might be beneficial
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1, assignedMember: nil))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func updateTicket(ticket: TicketRecord) async -> Result<TicketRecord, Error> {
        let tagsList: [Int] = ticket.tagList.map {$0.id}

        let writeTicket = WriteTicketRecord(tagList: tagsList,
                                            assignedUser: ticket.assignedUser?.id,
                                            status: ticket.status?.id,
                                            title: ticket.title,
                                            description: ticket.description,
                                            dueDate: ticket.dueDate)
        guard let body = BaseLoader.encode(object: writeTicket) else {
            let errorMessage = "Failed to serialize ticket JSON for updateTicket in TicketManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(ticket))
            .setMethod(method: .PUT)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)

    }
    public func deleteTicket(ticket: TicketRecord) async -> Result<Void, Error> {

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(ticket))
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        
        return await requestLoader.executeEmptyRequest(request: requestBuilder)

    }
}
