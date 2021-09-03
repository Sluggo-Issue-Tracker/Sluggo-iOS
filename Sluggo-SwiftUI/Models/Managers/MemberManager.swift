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
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest? = nil) {
        self.identity = identity
        self.requestLoader = requestLoader ?? JsonLoader(identity: self.identity)
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

    public func updateMemberRecord(_ memberRecord: MemberRecord) async -> Result<MemberRecord, Error> {

        guard let body = JsonLoader.encode(object: memberRecord) else {
            let errorMessage = "Failed to serialize member JSON for updateMemberRecord in MemberManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(id: memberRecord.id))
            .setData(data: body)
            .setMethod(method: .PUT)
            .setIdentity(identity: identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    func listFromTeams(page: Int) async -> Result<PaginatedList<MemberRecord>, Error> {

        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }

    public func getMemberRecord(user: AuthRecord,
                                identity: AppIdentity) async -> Result<MemberRecord, Error> {
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
        let requestBuilder = URLRequestBuilder(url: URL(string: makeDetailUrl(id: memberPk).absoluteString)!)
            .setMethod(method: .GET)
            .setIdentity(identity: identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder)
    }
}
