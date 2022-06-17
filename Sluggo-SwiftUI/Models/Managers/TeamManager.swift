//
//  TeamManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TeamManager {

    static let urlBase = "api/teams/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
    }

    func listFromTeams() async -> Result<[TeamRecord], Error> {

        let urlString = identity.baseAddress + TeamManager.urlBase
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func getTeam(team: TeamRecord) async -> Result<TeamRecord, Error> {
        let urlString = identity.baseAddress + TeamManager.urlBase + "\(team.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }
}
