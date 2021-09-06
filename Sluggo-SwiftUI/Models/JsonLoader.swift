//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader: BaseLoader, CanNetworkRequest {
    var identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    private func executeRefresh() async -> Result<RefreshRecord, Error> {
        let params = ["refresh": identity.refreshToken!] as [String: String]
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            let errorMessage = "Failed to serialize JSON for doRefresh in BaseLoader"
            return .failure(Exception.runtimeError(message: errorMessage))
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "token/refresh/")!)
            .setData(data: body)
            .setMethod(method: .POST)

        return await self.executeCodableRequest(request: requestBuilder)
    }
    

    /// This function will check to see if the response is an error that we can't handle, or if it's the specific refresh command.
    /// If it is an error it will return the error, otherwise it will return nil
    private func checkErrors(response: HTTPURLResponse, data: Data) -> Error? {
        if response.statusCode == 401 {
            guard let record: ErrorMessage = Self.decode(data: data) else {
                print(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
                let errorMessage = "Failure to decode retrieved error in JsonLoader Codable Request"
                return RESTException.failedRequest(message: errorMessage)
            }
            if record.code == "token_not_valid" {
                return nil
            }
        }
        
        let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
        let errorMessage = "HTTP Error \(response.statusCode): \(fetchedString)"
        return RESTException.failedRequest(message: errorMessage)
    }
    
    
    func executeCodableRequest<T: Codable>(request: URLRequestBuilder) async -> Result<T, Error> {
        
        let urlRequest = request.getRequest()

        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: urlRequest)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                guard let record: T = Self.decode(data: data) else {
                    print(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
                    let errorMessage = "Failure to decode retrieved model in JsonLoader Codable Request"
                    return .failure(RESTException.failedRequest(message: errorMessage))
                }
                return .success(record)
            } else {
                guard let capturedError = self.checkErrors(response: resp, data: data) else {
                    let refreshRecord = await self.executeRefresh()
                    switch refreshRecord {
                    case .success(let refresh):
                        self.identity.token = refresh.access
                        let refreshRequest = request.setIdentity(identity: identity)
                        return await self.executeCodableRequest(request: refreshRequest)
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                return .failure(capturedError)
            }
        }
        catch {
            return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }

    func executeEmptyRequest(request: URLRequestBuilder) async -> Result<Void, Error> {
        let urlRequest = request.getRequest()
        
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: urlRequest)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                return .success(())
            } else {
                guard let capturedError = self.checkErrors(response: resp, data: data) else {
                    let refreshRecord = await self.executeRefresh()
                    switch refreshRecord {
                    case .success(let refresh):
                        self.identity.token = refresh.access
                        let refreshRequest = request.setIdentity(identity: identity)
                        return await self.executeEmptyRequest(request: refreshRequest)
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                return .failure(capturedError)
            }
        }
        catch {
           return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }
}
