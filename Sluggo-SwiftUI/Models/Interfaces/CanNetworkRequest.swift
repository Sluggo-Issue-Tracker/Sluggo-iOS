//
//  CanNetworkRequest.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 7/13/21.
//

import Foundation

protocol CanNetworkRequest {
    
    static func decode<T: Codable>(data: Data) -> T?
    
    static func encode<T: Codable>(object data: T) -> Data?
    
    func executeCodableRequest<T: Codable>(request: URLRequestBuilder) async -> Result<T, Error>
    
    func executeEmptyRequest(request: URLRequestBuilder) async -> Result<Void, Error>
    
}
