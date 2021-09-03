//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader: BaseLoader, CanNetworkRequest {
    
    private func executeRefresh(identity: AppIdentity) async -> Result<RefreshRecord, Error> {
        let params = ["refresh": identity.refreshToken!] as [String: String]
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            let errorMessage = "Failed to serialize JSON for doRefresh in BaseLoader"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "auth/token/refresh/")!)
            .setData(data: body)
            .setMethod(method: .POST)

        return await self.executeCodableRequest(request: requestBuilder.getRequest())
    }
    
    func executeCodableRequest<T: Codable>(request: URLRequest) async -> Result<T, Error> {

        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: request)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                guard let record: T = Self.decode(data: data) else {
                    print(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
                    let errorMessage = "Failure to decode retrieved model in JsonLoader Codable Request"
                    return .failure(RESTException.failedRequest(message: errorMessage))
                }
                return .success(record)
            } else {
                let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
                let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                print(errorMessage)
                return .failure(RESTException.failedRequest(message: errorMessage))
            }
        }
        catch {
            return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }

    func executeEmptyRequest(request: URLRequest) async -> Result<Void, Error> {
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: request)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                return .success(())
            } else {
                let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
                let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                return .failure(RESTException.failedRequest(message: errorMessage))
            }
        }
        catch {
           return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }
}
