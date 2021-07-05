//
//  TagManger.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TagManager: TeamPaginatedListable {

    static let urlBase = "/tags/"
    private let identity: AppIdentity

    init(identity: AppIdentity) {
        self.identity = identity
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

    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<TagRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func makeTag(tag: WriteTagRecord,
                        completionHandler: @escaping(Result<TagRecord, Error>) -> Void) {
        guard let body = JsonLoader.encode(object: tag) else {
            let errorMessage = "Failed to serialize tag JSON for makeTag in TagManager"
            completionHandler(.failure(Exception.runtimeError(message: errorMessage)))
            return
        }

        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func deleteTag(tag: TagRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(tagRecord: tag))
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

}
