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

    init(_ identity: AppIdentity) {
        self.identity = identity
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

    public func listTeamTickets(page: Int,
                                queryParams: TicketFilterParameters,
                                completionHandler: @escaping (Result<PaginatedList<TicketRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page, queryParams: queryParams))
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func makeTicket(ticket: WriteTicketRecord,
                           completionHandler: @escaping(Result<TicketRecord, Error>) -> Void) {
        guard let body = JsonLoader.encode(object: ticket) else {
            let errorMessage = "Failed to serialize ticket JSON for makeTicket in TicketManager"
            completionHandler(.failure(Exception.runtimeError(message: errorMessage)))
            return
        }

        // NOTE: this works but the page here does effectively nothing. I think for clarity introducing a separate
        // function for making the url might be beneficial
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1, assignedMember: nil))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func updateTicket(ticket: TicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void) {
        let tagsList: [Int] = ticket.tagList.map {$0.id}

        let writeTicket = WriteTicketRecord(tagList: tagsList,
                                            assignedUser: ticket.assignedUser?.id,
                                            status: ticket.status?.id,
                                            title: ticket.title,
                                            description: ticket.description,
                                            dueDate: ticket.dueDate)
        guard let body = JsonLoader.encode(object: writeTicket) else {
            let errorMessage = "Failed to serialize ticket JSON for updateTicket in TicketManager"
            completionHandler(.failure(Exception.runtimeError(message: errorMessage)))
            return
        }

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(ticket))
            .setMethod(method: .PUT)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)

    }
    public func deleteTicket(ticket: TicketRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(ticket))
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)

    }
}
