//
//  MemberManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation
import CryptoKit

class MemberManager: TeamPaginatedListable {

    static let urlBase = "/members/"
    private var identity: AppIdentity

    init(identity: AppIdentity) {
        self.identity = identity
    }

    // swiftlint:disable:next identifier_name
    private func makeDetailUrl(id: String) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + MemberManager.urlBase + "\(id)/"
        return URL(string: urlString)!
    }

    private func makeListUrl(page: Int) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + MemberManager.urlBase + "?page=\(page)"
        return URL(string: urlString)!
    }

    public func updateMemberRecord(_ memberRecord: MemberRecord,
                                   completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) {

        guard let body = JsonLoader.encode(object: memberRecord) else {
            let errorMessage = "Failed to serialize member JSON for updateMemberRecord in MemberManager"
            completionHandler(.failure(Exception.runtimeError(message: errorMessage)))
            return
        }

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(id: memberRecord.id))
            .setData(data: body)
            .setMethod(method: .PUT)
            .setIdentity(identity: identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)

    }

    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<MemberRecord>, Error>) -> Void) {

        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func getMemberRecord(user: AuthRecord,
                                identity: AppIdentity,
                                completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) {
        // MARK: MD5 hashing convenience
        func MD5String(for str: String) -> String {
            let digest = Insecure.MD5.hash(data: str.data(using: .utf8)!)

            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        }

        // Calculate the member PK
        let teamHash = MD5String(for: String(identity.team!.id))
        let userHash = MD5String(for: user.username)

        let memberPk = teamHash.appending(userHash)

        // Execute request
        let request = URLRequestBuilder(url: URL(string: makeDetailUrl(id: memberPk).absoluteString)!)
            .setMethod(method: .GET)
            .setIdentity(identity: identity)

        JsonLoader.executeCodableRequest(request: request.getRequest(), completionHandler: completionHandler)
    }
}
