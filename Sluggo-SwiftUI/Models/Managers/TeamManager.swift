//
//  TeamManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TeamManager: TeamPaginatedListable {

    static let urlBase = "api/teams/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest = JsonLoader()) {
        self.identity = identity
        self.requestLoader = requestLoader
    }

    func listFromTeams(page: Int) async -> Result<PaginatedList<TeamRecord>, Error> {

        let urlString = identity.baseAddress + TeamManager.urlBase + "?page=\(page)"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func getTeam(team: TeamRecord) async -> Result<TeamRecord, Error> {
        let urlString = identity.baseAddress + TeamManager.urlBase + "\(team.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }
}
