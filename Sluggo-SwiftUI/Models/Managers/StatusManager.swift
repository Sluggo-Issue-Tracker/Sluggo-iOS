//
//  StatusManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

class StatusManager: TeamPaginatedListable {

    static let urlBase = "/statuses/"
    private let identity: AppIdentity

    init(identity: AppIdentity) {
        self.identity = identity
    }

    private func makeDetailUrl(statusRecord: StatusRecord) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + StatusManager.urlBase + "\(statusRecord.id)/"
        return URL(string: urlString)!
    }

    private func makeListUrl(page: Int) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + StatusManager.urlBase + "?page=\(page)"
        return URL(string: urlString)!
    }

    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<StatusRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
