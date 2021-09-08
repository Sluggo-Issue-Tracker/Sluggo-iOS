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
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
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

    func listFromTeams(page: Int) async -> Result<PaginatedList<StatusRecord>, Error>{
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }
}
