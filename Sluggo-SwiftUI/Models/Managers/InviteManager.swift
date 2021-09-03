//
//  InviteManager.swift
//  Sluggo
//
//  Created by Troy on 5/31/21.
//

import Foundation

// MARK: User Invite Manager
class InviteManager {

    static let urlBase = "api/users/invites/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
    }

    func getUserInvites() async -> Result<[UserInviteRecord], Error> {

        let urlString = identity.baseAddress + InviteManager.urlBase
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func acceptUserInvite(invite: UserInviteRecord) async -> Result<Void, Error> {

        let urlString = identity.baseAddress + InviteManager.urlBase + "\(invite.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setMethod(method: .PUT)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeEmptyRequest(request: requestBuilder)

    }

    public func rejectUserInvite(invite: UserInviteRecord) async -> Result<Void, Error> {

        let urlString = identity.baseAddress + InviteManager.urlBase + "\(invite.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeEmptyRequest(request: requestBuilder)

    }
}

// MARK: Team Invite Manager
class TeamInviteManager: TeamPaginatedListable {

    static let urlBase = "api/users/invites/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
    }

    func listFromTeams(page: Int) async -> Result<PaginatedList<TeamInviteRecord>, Error> {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)/" + "invites/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    func addTeamInvite(invite: WriteTeamInviteRecord) async -> Result<Void, Error> {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)/" + "invites/"

        guard let body = JsonLoader.encode(object: invite) else {
            let errorMessage = "Failed to serialize ticket JSON for addTeamInvite in InviteManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setData(data: body)
            .setMethod(method: .POST)

        return await requestLoader.executeEmptyRequest(request: requestBuilder)
    }

    func deleteTeamInvite(invite: TeamInviteRecord) async -> Result<Void, Error> {

        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)/" + "invites/" + "\(invite.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .DELETE)

        return await requestLoader.executeEmptyRequest(request: requestBuilder)
    }
}
