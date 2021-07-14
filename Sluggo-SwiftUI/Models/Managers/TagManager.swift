//
//  TagManger.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TagManager: TeamPaginatedListable {

    static let urlBase = "/tags/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest = JsonLoader()) {
        self.identity = identity
        self.requestLoader = requestLoader
    }

    private func makeDetailUrl(tagRecord: TagRecord) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase + "\(tagRecord.id)/"
        return URL(string: urlString)!
    }

    private func makeListUrl(page: Int) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase + "?page=\(page)"
        return URL(string: urlString)!
    }

    func listFromTeams(page: Int) async -> Result<PaginatedList<TagRecord>, Error> {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func makeTag(tag: WriteTagRecord) async -> Result<TagRecord, Error> {
        guard let body = type(of: requestLoader).encode(object: tag) else {
            let errorMessage = "Failed to serialize tag JSON for makeTag in TagManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func deleteTag(tag: TagRecord) async -> Result<Void, Error> {

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(tagRecord: tag))
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeEmptyRequest(request: requestBuilder.getRequest())
    }

}
