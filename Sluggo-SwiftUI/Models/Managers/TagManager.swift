//
//  TagManger.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TagManager {

    static let urlBase = "/tags/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
    }

    private func makeDetailUrl(tagRecord: TagRecord) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase + "\(tagRecord.id)/"
        return URL(string: urlString)!
    }

    private func makeListUrl() -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase
        return URL(string: urlString)!
    }

    func listFromTeams() async -> Result<[TagRecord], Error> {
        let requestBuilder = URLRequestBuilder(url: makeListUrl())
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func makeTag(tag: WriteTagRecord) async -> Result<TagRecord, Error> {
        guard let body = BaseLoader.encode(object: tag) else {
            let errorMessage = "Failed to serialize tag JSON for makeTag in TagManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: makeListUrl())
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func deleteTag(tag: TagRecord) async -> Result<Void, Error> {

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(tagRecord: tag))
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeEmptyRequest(request: requestBuilder)
    }

}
