//
//  UserManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class UserManager {
    static let urlBase = "auth/"
    private var identity: AppIdentity
    private let requestLoader: CanNetworkRequest

    init(identity: AppIdentity, requestLoader: CanNetworkRequest = JsonLoader()) {
        self.identity = identity
        self.requestLoader = requestLoader
    }

    public func getUser() async -> Result<AuthRecord, Error> {
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + "auth/user/")!)
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func doLogin(username: String,
                        password: String) async -> Result<TokenRecord, Error> {
        let params = ["username": username, "password": password] as [String: String]
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            let errorMessage = "Failed to serialize JSON for doLogin in UserManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "login/")!)
            .setData(data: body)
            .setMethod(method: .POST)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }
    
    public func doRefresh() async -> Result<RefreshRecord, Error> {
        let params = ["refresh": identity.refreshToken] as [String: String]
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            let errorMessage = "Failed to serialize JSON for doRefresh in UserManager"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "auth/token/refresh/")!)
            .setData(data: body)
            .setMethod(method: .POST)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }

    public func doLogout() async -> Result<LogoutMessage, Error>{
        let url = URL(string: identity.baseAddress + UserManager.urlBase + "logout/")!
        let requestBuilder = URLRequestBuilder(url: url)
            .setMethod(method: .POST)
            .setIdentity(identity: self.identity)

        return await requestLoader.executeCodableRequest(request: requestBuilder.getRequest())
    }
}
