//
//  RequestsTests.swift
//  CompoundTests
//
//  Created by JungSu Kim on 2021/02/02.
//

import XCTest
@testable import Compound

class RequestsTests: XCTestCase {
    
    func testSimpleRequests() throws {

        var number = 0
        let expectation = self.expectation(description: "simple.requests.expectation")

        let queue = RequestQueue { (queue, error) in
            XCTAssertEqual(number, 50)
            expectation.fulfill()
        }
        
        let request1 = Request {
            number += 5
            $0.finish()
        }
        
        let request2 = Request {
            number *= 10
            $0.finish()
        }
        
        let requests: Requests = [request1, request2]

        let request3 = Request {
            $0.finish()
        }

        queue.addOperations([requests, request3], waitUntilFinished: false)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testRequestsTransmitData() throws {
     
        var number = 0
        let expectation = self.expectation(description: "requests.transmit.data.expectation")

        let queue = RequestQueue { (queue, error) in
            XCTAssertEqual(number, 15)
            XCTAssertNotEqual(number, 50)
            expectation.fulfill()
        }
        
        let request1 = Request {
            number += 5
            $0.parent?["plus"] = true
            $0.finish()
        }
        
        let request2 = Request {

            if let boolValue = $0.parent?["plus"] as? Bool, boolValue == true {
                number += 10
            }
            else {
                number *= 10
            }
            
            $0.finish()
        }
        
        let requests: Requests = [request1, request2]
        queue.addOperation(requests)
        wait(for: [expectation], timeout: 10.0)
    }
}
