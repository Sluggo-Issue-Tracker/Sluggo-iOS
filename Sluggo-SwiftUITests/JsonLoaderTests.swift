//
//  Sluggo_SwiftUITests.swift
//  Sluggo-SwiftUITests
//
//  Created by Andrew Gavgavian on 7/5/21.
//

import XCTest
@testable import Sluggo_SwiftUI

class MockJsonLoader: BaseLoader, CanNetworkRequest {
    func executeCodableRequest<T: Codable>(request: URLRequestBuilder) async -> Result<T, Error> {
        let urlRequest = request.getRequest()
        let path = urlRequest.url
        let ticket = TicketRecord(id: 1,
                                  ticketNumber: 1,
                                  tagList: [],
                                  objectUuid: UUID(),
                                  assignedUser: nil,
                                  status: nil,
                                  title: "Test Ticket",
                                  description: nil,
                                  dueDate: nil,
                                  created: Date(),
                                  activated: nil,
                                  deactivated: nil)
        let tags = TagRecord(id: 1,
                             teamId: 1,
                             objectUuid: UUID(),
                             title: "Test Tag",
                             created: Date(),
                             activated: nil,
                             deactivated: nil)
        let status = StatusRecord(id: 1,
                                  objectUuid: UUID(),
                                  title: "Test Status",
                                  color: "#FFFFFFFF",
                                  created: Date(),
                                  activated: nil,
                                  deactivated: nil)
        if let urlString = path?.absoluteString {
            switch urlString {
            case _ where urlString.contains("/tickets/"):
                return .success(ticket as! T)
            case _ where urlString.contains("/tags/"):
                return .success(tags as! T)
            case _ where urlString.contains("/statuses/"):
                return .success(status as! T)
            default:
                break
            }
        }
        return .failure(RESTException.failedRequest(message: "Not an ticket, tag, or status url"))
    }
    
    func executeEmptyRequest(request: URLRequestBuilder) async -> Result<Void, Error> {
        return .success(())
    }
}

class JsonLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        track("Hi")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
