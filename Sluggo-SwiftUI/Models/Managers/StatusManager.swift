//
//  StatusManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

class StatusManager {
    
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

    private func makeListUrl() -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + StatusManager.urlBase
        return URL(string: urlString)!
    }

    func listFromTeams() async -> Result<[StatusRecord], Error>{
        let requestBuilder = URLRequestBuilder(url: makeListUrl())
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }
}
