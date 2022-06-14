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
    

    /// This function will take a 401 call and check to see if it's the specific refresh call. If so, we will try and update the access token,
    /// and recall the codable request to solve the issue of tokens.
    private func checkRefresh<T>(response: HTTPURLResponse, data: Data, request: URLRequestBuilder, completion: ((URLRequestBuilder) async -> Result<T, Error>)) async -> Result<T, Error>{
        guard let record: ErrorMessage = Self.decode(data: data) else {
            track(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
            let errorMessage = "Failure to decode retrieved error in JsonLoader Codable Request"
            return .failure(RESTException.failedRequest(message: errorMessage))
        }
    
        if record.code == "token_not_valid" {
            let refreshRecord = await self.executeRefresh()
            switch refreshRecord {
            case .success(let refresh):
                self.identity.token = refresh.access
                let refreshRequest = request.setIdentity(identity: identity)
                return await completion(refreshRequest)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
        let errorMessage = "HTTP Error \(response.statusCode): \(fetchedString)"
        return .failure(RESTException.failedRequest(message: errorMessage))
    }
    
    func executeCodableRequest<T: Codable>(request: URLRequestBuilder) async -> Result<T, Error> {
        
        let urlRequest = request.getRequest()

        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: urlRequest)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                guard let record: T = Self.decode(data: data) else {
                    track(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
                    let errorMessage = "Failure to decode retrieved model in JsonLoader Codable Request"
                    return .failure(RESTException.failedRequest(message: errorMessage))
                }
                return .success(record)
            } else {
                if resp.statusCode == 401 {
                    return await self.checkRefresh(response: resp, data: data, request: request, completion: executeCodableRequest)
                }
                
                let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
                let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                return .failure(RESTException.failedRequest(message: errorMessage))
            }
        }
        catch let error as NSError {
            return .failure(Exception.runtimeError(message: "\(error.localizedDescription)"))
        } catch {
            return .failure(Exception.runtimeError(message: "Server Error"))
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
                if resp.statusCode == 401 {
                    return await self.checkRefresh(response: resp, data: data, request: request, completion: executeEmptyRequest)
                }
                
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
