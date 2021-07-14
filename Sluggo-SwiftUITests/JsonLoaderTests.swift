//
//  Sluggo_SwiftUITests.swift
//  Sluggo-SwiftUITests
//
//  Created by Andrew Gavgavian on 7/5/21.
//

import XCTest
@testable import Sluggo_SwiftUI

class MockJsonLoader: BaseLoader, CanNetworkRequest {
    func executeCodableRequest<T: Codable>(request: URLRequest) async -> Result<T, Error> {
        return .failure(RESTException.failedRequest(message: "This is a Mock Error"))
    }
    
    func executeEmptyRequest(request: URLRequest) async -> Result<Void, Error> {
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
        print("Hi")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
