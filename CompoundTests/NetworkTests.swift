//
//  NetworkTests.swift
//  CompoundTests
//
//  Created by Clayton Kim on 2021/02/22.
//

import XCTest
@testable import Compound

struct Sample: Decodable {
    var title: String
}

class NetworkTests: XCTestCase {

    func testSimpleNetworkRequest() throws {
        
        let expectation = XCTestExpectation(description: "simple network request")
        var completedCount = 0
        
        let queue = NetworkQueue(configuration: .default) { queue, error in
            XCTAssert(completedCount == 2)
            expectation.fulfill()
        }
        
        let req1 = Network(path: "https://hacker-news.firebaseio.com/v0/item/1000.json")
        req1.customCompletion = { request, error in
            completedCount += 1
        }

        let req2 = Network(path: "https://hacker-news.firebaseio.com/v0/item/1001.json")
        req2.customCompletion = { request, error in
            completedCount += 1
        }

        queue.addOperation(req1)
        queue.addOperation(req2)
        wait(for: [expectation], timeout: 10)
    }

}
